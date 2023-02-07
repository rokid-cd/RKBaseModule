//
//  RKDocumentPreviewVC.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

import UIKit
import SnapKit
import QuickLook

class RKDocumentPreviewVC: UIViewController {
    
    var filePath: String?
    
    private var loacalFileURL: URL?
    
    let imageView: UIImageView = UIImageView()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: 0x333333)
        lab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lab.textAlignment = .center
        lab.numberOfLines = 2
        return lab
    }()
    
    lazy var infoLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: 0x8FA2C3)
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.text = ""
        return lab
    }()
    
    lazy var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = .init(hex: 0x0AC934)
        progress.trackTintColor = .init(hex: 0xE4E7EE)
        progress.isHidden = true
        return progress
    }()
    
    lazy var actionButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(hex: 0x194BFB)
        btn.layer.cornerRadius = 2
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(fileAction), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    var actionState: RKFileActionState = .normal {
        didSet {
            actionButton.isHidden = false
            actionButton.setTitle(actionState.title, for: .normal)
            switch actionState {
            case .normal:
                infoLab.text = "系统暂时无法预览该文件，请用其他应用打开预览"
                let size = try? String(Data(contentsOf: loacalFileURL!).count).sizeFormat
                let info = "用其他应用打开" + (size != nil ? "(\(size!))" : "")
                actionButton.setTitle(info, for: .normal)
                progressView.progress = 0
                progressView.isHidden = true
            case .download:
                progressView.isHidden = false
            case .pause:
                progressView.isHidden = false
            case .fail:
                infoLab.text = "下载失败"
                progressView.progress = 0
                progressView.isHidden = true
            }
        }
    }
    
    enum RKFileActionState {
        case normal     //其他应用打开
        case download   //继续下载
        case pause      //暂停下载
        case fail       //失败，重新下载
        var title: String {
            switch self {
            case .normal:
                return "用其他应用打开"
            case .download:
                return "继续下载"
            case .pause:
                return "暂停下载"
            case .fail:
                return "重新下载"
            }
        }
    }
    
    enum RKDocumentFileType: String {
        case pdf
        case doc, docx, word
        case ppt, pptx
        case xlsx, excel
        case txt
        case other
        
        var image: UIImage? {
            var imgName = "other"
            switch self {
            case .doc, .docx, .word:
                imgName = "doc"
            case .ppt, .pptx:
                imgName = "ppt"
            case .excel, .xlsx:
                imgName = "excel"
            default:
                imgName = rawValue
            }
            return UIImage(named: "rk_file_\(imgName)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    func setupUI() {
        view.backgroundColor = .white
        
        let contentView = UIView()
        contentView.addSubview(imageView)
        contentView.addSubview(titleLab)
        
        let actionView = UIView()
        actionView.addSubview(actionButton)
        view.addSubview(contentView)
        view.addSubview(infoLab)
        view.addSubview(progressView)
        view.addSubview(actionView)
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(52)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(imageView.snp.bottom).offset(18)
        }
        
        contentView.snp.makeConstraints { make in
            let navH = self.navigationController?.navigationBar.bounds.height ?? 0
            let statusH = UIApplication.shared.statusBarFrame.height
            make.top.equalToSuperview().offset(navH+statusH)
            make.left.right.equalToSuperview()
        }
        
        infoLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview().offset(-15)
            make.top.equalTo(contentView.snp.bottom)
        }
        
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(210)
            make.height.equalTo(4)
            make.top.equalTo(infoLab.snp_bottom).offset(12)
        }
        
        actionView.snp.makeConstraints { make in
            make.top.equalTo(infoLab.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(46)
            make.centerY.equalToSuperview()
        }
    }
    
    func loadData() {
        
        guard let path = filePath else { return }
        
        let fileUrl = URL(fileURLWithPath: path)
        title = fileUrl.lastPathComponent
        let extensionName = fileUrl.pathExtension
        let fileType = RKDocumentFileType(rawValue: extensionName) ?? .other
        imageView.image = fileType.image
        titleLab.text = title
        
        self.infoLab.text = "正在下载(0/0)"
        self.actionState = .pause
        RKDownloadManager.downLoadFile(fileUrlPath: path) {[weak self] progress in
            let totalFormat = String(progress.totalUnitCount).sizeFormat
            let downFormat = String(progress.completedUnitCount).sizeFormat
            self?.infoLab.text = "正在下载(\(downFormat)/\(totalFormat))"
            self?.progressView.observedProgress = progress
            
        } completion: { [weak self] error, path in
            guard let self = self else { return }
            if let _ = error {
                self.actionState = .fail
            } else {
                self.showDocumentInteractionController(fileUrl: URL(fileURLWithPath: path))
            }
        }
    }
    
    func showDocumentInteractionController(fileUrl: URL) {
        loacalFileURL = fileUrl
        
        if QLPreviewController.canPreview(fileUrl as NSURL) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(fileAction))
            
            let vc = QLPreviewController()
            vc.dataSource = self
            vc.currentPreviewItemIndex = 0
            view.addSubview(vc.view)
            addChild(vc)
            vc.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.actionState = .normal
        } else {
            if fileUrl.isFileURL {
                self.actionState = .normal
            } else {
                self.actionState = .fail
            }
        }
    }
    
    @objc func fileAction() {
        
        switch actionState {
        case .normal:
            guard let fileUrl = loacalFileURL else { return }
            let vc = UIDocumentInteractionController(url: fileUrl)
            vc.delegate = self
            vc.name = fileUrl.lastPathComponent
            vc.presentOptionsMenu(from: actionButton.frame, in: self.view, animated: true)
            
        case .download:
            guard let path = filePath else { return }
            RKDownloadManager.resume(filePath: path)
            actionState = .pause
        case .pause:
            guard let path = filePath else { return }
            RKDownloadManager.suspend(filePath: path)
            actionState = .download
        case .fail:
            loadData()
            actionState = .pause
        }
    }
}

extension RKDocumentPreviewVC: QLPreviewControllerDataSource, UIDocumentInteractionControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
     
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.loacalFileURL! as NSURL
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
