//
//  RKPreviewViewCell.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

import UIKit
import KSYMediaPlayer
import Kingfisher
import PhotosUI

class RKPreviewVideoCell: UIView, JXPhotoBrowserCell {
    
    class ARIMSlider: UISlider {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let bounds: CGRect = self.bounds.insetBy(dx: -20, dy: -20)
            return bounds.contains(point)
        }
    }
    
    var autoPlay = false
    weak var photoBrowser: JXPhotoBrowser?
    private var videoModel: RKFileModel?
    
    private lazy var mediaPlayer: KSYMoviePlayerController = {
        let player = KSYMoviePlayerController()
        player.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.shouldAutoplay = false
        return player
    }()
    
    private let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    
    lazy var indicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .whiteLarge))
    
    private lazy var playButton: UIButton = {
        $0.frame.size = CGSize(width: 46, height: 46)
        $0.setImage(Bundle.rkImage(named: "rk_video_play"), for: .normal)
        $0.setImage(Bundle.rkImage(named: "rk_video_pause"), for: .selected)
        $0.addTarget(self, action: #selector(play), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    private lazy var downloadButton: UIButton = {
        $0.setImage(Bundle.rkImage(named: "rk_chat_down"), for: .normal)
        $0.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    private lazy var dismissButton: UIButton = {
        $0.frame = CGRect(x: 15, y: bounds.height-46-35, width: 46, height: 46)
        $0.layer.cornerRadius = 23
        $0.setImage(Bundle.rkImage(named: "rk_arrow_down"), for: .normal)
        $0.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    private lazy var curTimeLabel: UILabel = {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.text = "00:00"
        return $0
    }(UILabel())
    
    private lazy var totalTimeLabel: UILabel = {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.text = "00:00"
        return $0
    }(UILabel())
    
    private lazy var sliderView: ARIMSlider = {
        $0.minimumTrackTintColor = .init(hex: 0x194BFB)
        $0.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.6)
        $0.setThumbImage(Bundle.rkImage(named: "rk_video_thumb").cicleImage(), for: .normal)
        $0.addTarget(self, action: #selector(sliderBeginAction), for: .touchDown)
        $0.addTarget(self, action: #selector(sliderChangeAction), for: .valueChanged)
        $0.addTarget(self, action: #selector(sliderAction), for: .touchUpInside)
        return $0
    }(ARIMSlider())
    
    lazy var sizeLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white
        $0.layer.cornerRadius = 2
        $0.isHidden = true
        $0.backgroundColor = UIColor(hex: 0x2C2C2C).withAlphaComponent(0.6)
        $0.text = "文件大小：0b"
        return $0
    }(UILabel())
    
    static func generate(with browser: JXPhotoBrowser) -> Self {
        let instance = Self.init(frame: .zero)
        instance.photoBrowser = browser
        return instance
    }

    required override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .black
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        imageView.addGestureRecognizer(tap)
        imageView.addSubview(mediaPlayer.view)
        addSubview(imageView)
        addSubview(downloadButton)
        addSubview(dismissButton)
        addSubview(curTimeLabel)
        addSubview(sliderView)
        addSubview(totalTimeLabel)
        addSubview(sizeLabel)
        addSubview(indicatorView)
        addSubview(playButton)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer.removeObserver(self, forKeyPath: "currentPlaybackTime")
        mediaPlayer.stop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        mediaPlayer.view.frame = imageView.bounds
        playButton.center = imageView.center
        indicatorView.center = imageView.center
        downloadButton.frame = CGRect(x: bounds.width-92-30, y: bounds.height-46-35, width: 46, height: 46)
        dismissButton.frame = CGRect(x: bounds.width-46-15, y: bounds.height-46-35, width: 46, height: 46)
        curTimeLabel.frame = CGRect(x: 15, y: bounds.height-120, width: 46, height: 20)
        totalTimeLabel.frame = CGRect(x: bounds.width-46-15, y: bounds.height-120, width: 46, height: 20)
        sliderView.frame = CGRect(x: 66, y: bounds.height-112, width: bounds.width-132, height: 2)
        sizeLabel.frame = CGRect(x: 15, y: bounds.height-31-43, width: 140, height: 31)
    }
    
    private func setupObservers() {
        mediaPlayer.addObserver(self, forKeyPath: "currentPlaybackTime", options: .new, context: nil)
        registerObserver(name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish)
        registerObserver(name: NSNotification.Name.MPMoviePlayerLoadStateDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered)
    }
    
    private func registerObserver(name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: name, object: mediaPlayer)
    }
    
    private var reloading = false
    @objc private func handlePlayerNotify(notify: NSNotification) {

        if NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange == notify.name {
            formatTime(time: mediaPlayer.duration, label: totalTimeLabel)
            if autoPlay {
                mediaPlayer.play()
                playButton.isSelected = true
                timerShowControl()
            }
            reloading = false
        }
        if NSNotification.Name.MPMoviePlayerLoadStateDidChange ==  notify.name {
            if mediaPlayer.loadState == .stalled {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
        }
        if NSNotification.Name.MPMoviePlayerPlaybackDidFinish == notify.name {
            initializeUIValue()
            reloading = true
            
        }
        if NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered == notify.name {
            mediaPlayer.shouldHideVideo = false
            mediaPlayer.view.isHidden = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentPlaybackTime" {
            guard !reloading, !isSlider, mediaPlayer.duration > 0 else { return }
            formatTime(time: mediaPlayer.currentPlaybackTime, label: curTimeLabel)
            sliderView.setValue(Float(mediaPlayer.currentPlaybackTime/mediaPlayer.duration), animated: true)
        }
    }
    
    func reloadVideo(_ model: RKFileModel) {
        
        guard let url = URL(string: model.fileUrl) else { return }
        
        videoModel = model
        
        mediaPlayer.reset(false)
        initializeUIValue()
        mediaPlayer.setUrl(url)
        mediaPlayer.prepareToPlay()
        
        if let fileSize = model.size {
            self.sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
        } else {
            RKDownloadManager.videoSize(fileUrl: url) { fileSize in
                self.sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
                self.videoModel?.size = fileSize
            }
        }
    }
    
    private func initializeUIValue() {
        mediaPlayer.shouldHideVideo = true
        mediaPlayer.view.isHidden = true
        sliderView.setValue(0, animated: false)
        sliderView.isHidden = false
        totalTimeLabel.isHidden = false
        curTimeLabel.isHidden = false
        downloadButton.isHidden = false
        dismissButton.isHidden = false
        playButton.isHidden = false
        playButton.isSelected = false
        sizeLabel.isHidden = false
        indicatorView.stopAnimating()
        formatTime(time: 0, label: curTimeLabel)
        if mediaPlayer.duration > 0 {
            formatTime(time: mediaPlayer.duration, label: totalTimeLabel)
        } else if let duration = videoModel?.duration  {
            formatTime(time: Double(duration) ?? 0, label: totalTimeLabel)
        }
        thumImage()
    }
    
    private func thumImage() {
        guard let model = videoModel else { return }
        RKFilePreview.thumbnailImage(filePath: model.fileUrl) {[weak self] image in
            if let image = image {
                self?.imageView.image = image
            } else if let thumbUrl = URL(string: model.thumbUrl) {
                RKDownloadManager.trustHost(fileUrl: thumbUrl)
                self?.imageView.kf.setImage(with: thumbUrl)
            }
        }
    }
    
    private func formatTime(time: Double, label: UILabel) {

        let timeM = Int(ceil(time))/60
        let timeS = Int(ceil(time))%60
        label.text = String(format:"%0.2d:%0.2d", timeM,timeS)
    }
    
    @objc func play() {
        if mediaPlayer.isPlaying() {
            mediaPlayer.pause()
            playButton.isSelected = false
        } else {
            playButton.isSelected = true
            if reloading, let model = videoModel, let url = URL(string: model.fileUrl) {
                mediaPlayer.reload(url)
            } else {
                mediaPlayer.play()
                timerShowControl()
            }
        }
    }
    
    func stop() {
        mediaPlayer.pause()
        playButton.isSelected = false
        changeControlState(hidden: false)
    }
    
    private func timerShowControl() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        perform(#selector(hiddenControl), with: nil, afterDelay: 3)
    }
    
    @objc private func dismissAction() {
        mediaPlayer.stop()
        photoBrowser?.dismiss()
    }

    @objc private func tapClick() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        changeControlState(hidden: !playButton.isHidden)
        if !playButton.isHidden {
            perform(#selector(hiddenControl), with: nil, afterDelay: 3)
        }
    }
    
    @objc private func hiddenControl() {
        changeControlState(hidden: true)
    }
    
    @objc private func changeControlState(hidden: Bool = true) {
        guard !isSlider, mediaPlayer.isPlaying() else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.playButton.isHidden = hidden
            self.dismissButton.isHidden = hidden
            self.curTimeLabel.isHidden = hidden
            self.totalTimeLabel.isHidden = hidden
            self.sliderView.isHidden = hidden
            self.downloadButton.isHidden = hidden
            self.sizeLabel.isHidden = hidden
        }
    }
    
    private var isSlider = false
    @objc private func sliderBeginAction() {
        isSlider = true
    }
    
    @objc private func sliderChangeAction() {
        guard mediaPlayer.duration > 0 else { return }
        let time = mediaPlayer.duration * Double(sliderView.value)
        formatTime(time: time, label: curTimeLabel)
    }
    
    @objc private func sliderAction() {
        let time = mediaPlayer.duration * Double(sliderView.value)
        mediaPlayer.seek(to: time, accurate: true)
        isSlider = false
    }
}

extension RKPreviewVideoCell {
    @objc private func downloadAction() {
        
        guard let model = videoModel else { return }
        RKMiddleware.share.promptDelegate?.showLoading(inView: self) ?? RKHUD.show()
        RKDownloadManager.downLoadFile(fileUrlPath: model.fileUrl) { progress in
            
        } completion: {[weak self] error, path in
            RKMiddleware.share.promptDelegate?.hidenLoading(inView: self) ?? RKHUD.remove()
            guard let self = self else { return }
            if let _ = error {
                RKMiddleware.share.promptDelegate?.showToast(withText: "下载失败", inView: self) ?? RKHUD.showToast(status: "下载失败")
            } else {
                self.saveLoacalVideo(URL(fileURLWithPath: path))
            }
        }
    }
    
    private func saveLoacalVideo(_ fileUrl: URL) {
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
        } completionHandler: { success, error in
            if (success) {
                RKMiddleware.share.promptDelegate?.showToast(withText: "保存成功", inView: self) ?? RKHUD.showToast(status: "保存成功")
            } else {
                RKMiddleware.share.promptDelegate?.showToast(withText: "保存失败", inView: self) ?? RKHUD.showToast(status: "保存失败")
            }
        }
    }
}


/// 加载进度环
open class JXPhotoBrowserProgressView: UIView {
    
    /// 进度
    open var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.fanshapedLayer.path = self.makeProgressPath(self.progress).cgPath
                if self.progress >= 1.0 || self.progress < 0.01 {
                    self.isHidden = true
                } else {
                    self.isHidden = false
                }
            }
        }
    }
    /// 外边界
    private var circleLayer: CAShapeLayer!
    
    /// 扇形区
    private var fanshapedLayer: CAShapeLayer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if self.frame.size.equalTo(.zero) {
            self.frame.size = CGSize(width: 50, height: 50)
        }
        setupUI()
        progress = 0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        let strokeColor = UIColor(white: 1, alpha: 0.8).cgColor
        
        circleLayer = CAShapeLayer()
        circleLayer.strokeColor = strokeColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.path = makeCirclePath().cgPath
        layer.addSublayer(circleLayer)
        
        fanshapedLayer = CAShapeLayer()
        fanshapedLayer.fillColor = strokeColor
        layer.addSublayer(fanshapedLayer)
    }
    
    private func makeCirclePath() -> UIBezierPath {
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: arcCenter, radius: 25, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        path.lineWidth = 2
        return path
    }
    
    private func makeProgressPath(_ progress: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.midY - 2.5
        let path = UIBezierPath()
        path.move(to: center)
        path.addLine(to: CGPoint(x: bounds.midX, y: center.y - radius))
        path.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2 * progress, clockwise: true)
        path.close()
        path.lineWidth = 1
        return path
    }
}


class RKPreviewImageCell: JXPhotoBrowserImageCell {

    let progressView = JXPhotoBrowserProgressView()
    
    lazy var downloadButton: UIButton = {
        $0.setImage(Bundle.rkImage(named: "rk_chat_down"), for: .normal)
        $0.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    lazy var sizeLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white
        $0.layer.cornerRadius = 2
        $0.backgroundColor = UIColor(hex: 0x2C2C2C).withAlphaComponent(0.6)
        $0.text = "文件大小：0b"
        return $0
    }(UILabel())
    
    override func setup() {
        super.setup()
        addSubview(progressView)
        addSubview(downloadButton)
        addSubview(sizeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        downloadButton.frame = CGRect(x: bounds.width-46-15, y: bounds.height-46-35, width: 46, height: 46)
        sizeLabel.frame = CGRect(x: 15, y: bounds.height-31-43, width: 140, height: 31)
    }
    
    override func onPan(_ pan: UIPanGestureRecognizer) {
        super.onPan(pan)
        switch pan.state {
        case .began:
            progressView.alpha = 0
            downloadButton.alpha = 0
            sizeLabel.alpha = 0
            
        case .ended, .cancelled:
            let alpha = photoBrowser?.maskView.alpha ?? 0
            progressView.alpha = alpha
            downloadButton.alpha = alpha
            sizeLabel.alpha = alpha
        default: break
        }
    }
    
    func reloadImage(_ model: RKFileModel) {
        
        guard let url = URL(string: model.fileUrl) else { return }
        
        RKDownloadManager.trustHost(fileUrl: url)
        
        if let fileSize = model.size, Double(fileSize) ?? 0 > 0{
            sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
        }
        
        imageView.kf.setImage(with: URL(string: model.thumbUrl))
        
        progressView.progress = 0
        imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.25)),
             .keepCurrentImageWhileLoading]) {[weak self] receivedSize, totalSize in
                 guard let self = self else { return }
                 if totalSize > 0 {
                     let sizeFormat = String(totalSize).sizeFormat
                     self.sizeLabel.text = "文件大小：\(sizeFormat)"
                     self.progressView.progress = CGFloat(receivedSize) / CGFloat(totalSize)
                 }
             } completionHandler: {[weak self] result in
                 guard let self = self else { return }
                 switch result {
                 case .failure(_):
                     self.progressView.progress = 0
                     self.setNeedsLayout()
                 case let .success(data):
                     self.progressView.progress = 1.0
                     let image = data.image
                     DispatchQueue.global().async {
                         let sizeFormat = String(image.jpegData(compressionQuality: 1.0)?.count ?? 0).sizeFormat
                         DispatchQueue.main.async {
                             self.sizeLabel.text = "文件大小：\(sizeFormat)"
                         }
                     }
                     self.setNeedsLayout()
                 }
             }
    }
    
    //保存到相册
    @objc func downloadAction() {
        guard let image = imageView.image else {
            RKMiddleware.share.promptDelegate?.showToast(withText: "保存失败", inView: self) ?? RKHUD.showToast(status: "保存失败")
            return
        }
        RKMiddleware.share.promptDelegate?.showLoading(inView: self) ?? RKHUD.show()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        RKMiddleware.share.promptDelegate?.hidenLoading(inView: self) ?? RKHUD.remove()
        if error != nil {
            RKMiddleware.share.promptDelegate?.showToast(withText: "保存失败", inView: self) ?? RKHUD.showToast(status: "保存失败")
        }else{
            RKMiddleware.share.promptDelegate?.showToast(withText: "保存成功", inView: self) ?? RKHUD.showToast(status: "保存成功")
        }
    }
}
