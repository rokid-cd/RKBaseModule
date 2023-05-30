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
    
    var autoPlay = false
    weak var photoBrowser: JXPhotoBrowser?
    private var videoModel: RKFileModel?
    
    private lazy var topView: UIView = {
        $0.backgroundColor = .white
        $0.addSubview(self.dismissButton)
        $0.isHidden = true
        return $0
    }(UIView())
    
    private lazy var dismissButton: UIButton = {
        $0.setImage(Bundle.rkImage(named: "rk_back"), for: .normal)
        $0.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        $0.titleLabel?.lineBreakMode = .byTruncatingTail
        $0.contentHorizontalAlignment = .left
        return $0
    }(UIButton(type: .custom))
    
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
        $0.setImage(Bundle.rkImage(named: "rk_video_pauseBig"), for: .normal)
        $0.setImage(Bundle.rkImage(named: "rk_video_playBig"), for: .selected)
        $0.addTarget(self, action: #selector(play), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    private lazy var downloadButton: UIButton = {
        $0.setImage(Bundle.rkImage(named: "rk_chat_down"), for: .normal)
        $0.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))
    
    private var progressView = RKProgressView()
    
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
        backgroundColor = .clear
        imageView.addSubview(mediaPlayer.view)
        addSubview(imageView)
        addSubview(downloadButton)
        addSubview(progressView)
        addSubview(sizeLabel)
        addSubview(indicatorView)
        addSubview(playButton)
        addSubview(topView)
        setupObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        imageView.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer.removeObserver(self, forKeyPath: "currentPlaybackTime")
        mediaPlayer.stop()
        RKPrompt.hidenLoading()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if beganFrame == .zero {
            imageView.frame = bounds
            mediaPlayer.view.frame = imageView.bounds
        }
        topView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: UIApplication.shared.statusBarFrame.height + 44)
        dismissButton.frame = CGRect(x: 15, y: UIApplication.shared.statusBarFrame.height, width: bounds.width - 30, height: 44)
        playButton.center = imageView.center
        indicatorView.center = imageView.center
        downloadButton.frame = CGRect(x: bounds.width-46-15, y: bounds.height-46-35, width: 46, height: 46)
        progressView.frame = CGRect(x: 15, y: bounds.height-120, width: bounds.width-30, height: 20)
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
            progressView.totalTimeSeconds = Float(mediaPlayer.duration)
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
            self.imageView.image = nil
            self.mediaPlayer.view.isHidden = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentPlaybackTime" {
            guard mediaPlayer.duration > 0 else { progressView.cacheProgress = 0; return }
            progressView.cacheProgress = Float(mediaPlayer.playableDuration/mediaPlayer.duration)
            guard !reloading, !progressView.isDragSlider else { return }
            progressView.playProgress = Float(mediaPlayer.currentPlaybackTime/mediaPlayer.duration)
        }
    }
    
    func reloadVideo(_ model: RKFileModel) {
        
        guard let url = model.fileUrl else { return }
        
        videoModel = model
        topView.isHidden = model.fileName?.isEmpty ?? true
        dismissButton.setTitle("  \(model.fileName ?? "")", for: .normal)
        mediaPlayer.reset(false)
        initializeUIValue()
        mediaPlayer.setUrl(url)
        mediaPlayer.prepareToPlay()
        progressView.dragingSliderClosure = {[weak self] progress in
            guard let self = self else { return }
            let time = self.mediaPlayer.duration * Double(progress)
            self.mediaPlayer.seek(to: time, accurate: true)
        }
        if let fileSize = model.size, Double(fileSize) ?? 0 > 0 {
            sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
        } else {
            sizeLabel.rk_fileSize(fileUrl: url) { [weak self] fileSize in
                self?.sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
                self?.videoModel?.size = fileSize
            }
        }
        if !url.isFileURL, RKDownloadManager.isDownloading(fileUrl: url) { downloadVideo() }
    }
    
    private func initializeUIValue() {
        mediaPlayer.view.isHidden = true
        progressView.playProgress = 0
        progressView.isHidden = false
        downloadButton.isHidden = false
        playButton.isHidden = false
        playButton.isSelected = false
        sizeLabel.isHidden = false
        topView.alpha = 1
        topView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: UIApplication.shared.statusBarFrame.height + 44)
        indicatorView.stopAnimating()
        if mediaPlayer.duration > 0 {
            progressView.totalTimeSeconds = Float(mediaPlayer.duration)
        } else if let duration = videoModel?.duration  {
            progressView.totalTimeSeconds = Float(duration) ?? 0
        }
        thumImage()
    }
    
    private func thumImage() {
        guard let url = videoModel?.fileUrl else { return }
        imageView.rk_videoThumbnailImage(fileUrl: url) {[weak self] image in
            if image == nil, let thumbUrl = self?.videoModel?.thumbUrl {
                self?.imageView.kf.setImage(with: thumbUrl)
            }
        }
    }
    
    @objc func play() {
        if mediaPlayer.isPlaying() {
            mediaPlayer.pause()
            playButton.isSelected = false
        } else {
            playButton.isSelected = true
            if reloading, let model = videoModel, let url = model.fileUrl {
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
        RKPrompt.hidenLoading()
    }
    
    private func timerShowControl() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        perform(#selector(hiddenControl), with: nil, afterDelay: 3)
    }
    
    @objc private func dismissAction() {
        mediaPlayer.stop()
        photoBrowser?.dismiss()
    }

    @objc private func onTap() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        changeControlState(hidden: !playButton.isHidden)
        if !playButton.isHidden {
            perform(#selector(hiddenControl), with: nil, afterDelay: 3)
        }
    }
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    @objc open func onPan(_ pan: UIPanGestureRecognizer) {

        switch pan.state {
        case .began:
            beganFrame = imageView.frame
            beganTouch = pan.location(in: self)
            progressView.alpha = 0
            downloadButton.alpha = 0
            sizeLabel.alpha = 0
            playButton.alpha = 0
            topView.alpha = 0
        case .changed:
            let result = panResult(pan)
            imageView.frame = result.frame
            photoBrowser?.maskView.alpha = result.scale * result.scale
            photoBrowser?.setStatusBar(hidden: false)
            photoBrowser?.pageIndicator?.isHidden = result.scale < 0.99
        case .ended, .cancelled:
            imageView.frame = panResult(pan).frame
            let isDown = pan.velocity(in: self).y > 0
            if isDown {
                photoBrowser?.dismiss()
            } else {
                photoBrowser?.maskView.alpha = 1.0
                photoBrowser?.setStatusBar(hidden: false)
                photoBrowser?.pageIndicator?.isHidden = false
                resetImageViewPosition()
            }
            let alpha = photoBrowser?.maskView.alpha ?? 0
            progressView.alpha = alpha
            downloadButton.alpha = alpha
            sizeLabel.alpha = alpha
            playButton.alpha = alpha
            topView.alpha = sizeLabel.isHidden ? 0 : alpha
        default:
            resetImageViewPosition()
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: self)
        let currentTouch = pan.location(in: self)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    /// 复位ImageView
    private func resetImageViewPosition() {
        UIView.animate(withDuration: 0.25) {
            self.imageView.frame = CGRect(origin: .zero, size: self.bounds.size)
            self.mediaPlayer.view.frame = self.imageView.bounds
        } completion: { _ in
            self.beganFrame = .zero
            self.beganTouch = .zero
        }
    }
    
    @objc private func hiddenControl() {
        changeControlState(hidden: true)
    }
    
    @objc private func changeControlState(hidden: Bool = true) {
        guard !progressView.isDragSlider, mediaPlayer.isPlaying() else {
            return
        }
        playButton.isHidden = hidden
        progressView.isHidden = hidden
        downloadButton.isHidden = hidden
        sizeLabel.isHidden = hidden
        
        UIView.animate(withDuration: 0.2) {
            self.topView.alpha = hidden ? 0 : 1
            let height = self.topView.bounds.size.height
            self.topView.frame = CGRect(x: 0, y: hidden ? -height : 0, width: self.bounds.width, height: height)
        }
    }
}

extension RKPreviewVideoCell {
    @objc private func downloadAction() {
        
        guard let fileUrl = videoModel?.fileUrl else { return }
        if fileUrl.isFileURL {
            self.saveLoacalVideo(fileUrl)
        } else {
            guard !RKDownloadManager.isDownloading(fileUrl: fileUrl) else { return }
            downloadVideo()
        }
    }
    
    private func downloadVideo() {
        guard let fileUrl = videoModel?.fileUrl else { return }
        let sizeText = sizeLabel.text
        RKDownloadManager.downLoadFile(fileUrl: fileUrl) { [weak self] progress in
            let totalCount = progress.totalUnitCount
            let completedCount = progress.completedUnitCount
            guard let self = self, totalCount > 0 else { return }
            self.sizeLabel.text = "\(Int(Double(completedCount)/Double(totalCount) * 100))%"
            if completedCount >= totalCount {
                self.sizeLabel.text = "下载完成"
            }
        } completion: { [weak self] error, path in
            guard let self = self else { return }
            if let _ = error {
                RKPrompt.showToast(withText: "视频保存失败", inView: self)
                self.sizeLabel.text = sizeText
            } else {
                self.saveLoacalVideo(URL(fileURLWithPath: path))
                self.sizeLabel.text = sizeText
            }
        }
    }
    
    private func saveLoacalVideo(_ fileUrl: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if (success) {
                    RKPrompt.showToast(withText: "视频保存成功", inView: self)
                } else {
                    RKPrompt.showToast(withText: "视频保存失败", inView: self)
                }
            }
        }
    }
}

extension RKPreviewVideoCell: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只处理pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
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
    
    var imageModel: RKFileModel?
    private lazy var topView: UIView = {
        $0.backgroundColor = .white
        $0.addSubview(self.dismissButton)
        $0.isHidden = true
        return $0
    }(UIView())
    
    private lazy var dismissButton: UIButton = {
        $0.setImage(Bundle.rkImage(named: "rk_back"), for: .normal)
        $0.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        $0.titleLabel?.lineBreakMode = .byTruncatingTail
        $0.contentHorizontalAlignment = .left
        return $0
    }(UIButton(type: .custom))
    
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
        addSubview(topView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        downloadButton.frame = CGRect(x: bounds.width-46-15, y: bounds.height-46-35, width: 46, height: 46)
        sizeLabel.frame = CGRect(x: 15, y: bounds.height-31-43, width: 140, height: 31)
        topView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: UIApplication.shared.statusBarFrame.height + 44)
        dismissButton.frame = CGRect(x: 15, y: UIApplication.shared.statusBarFrame.height, width: bounds.width - 30, height: 44)
    }
    
    @objc private func dismissAction() {
        photoBrowser?.dismiss()
    }
    
    override func onPan(_ pan: UIPanGestureRecognizer) {
        super.onPan(pan)
        switch pan.state {
        case .began:
            progressView.alpha = 0
            downloadButton.alpha = 0
            sizeLabel.alpha = 0
            topView.alpha = 0
            photoBrowser?.setStatusBar(hidden: false)
            
        case .ended, .cancelled:
            let alpha = photoBrowser?.maskView.alpha ?? 0
            progressView.alpha = alpha
            downloadButton.alpha = alpha
            sizeLabel.alpha = alpha
            topView.alpha = sizeLabel.isHidden ? 0 : alpha
            photoBrowser?.setStatusBar(hidden: false)
        default: break
        }
    }
    
    /// 单击
    @objc override func onSingleTap(_ tap: UITapGestureRecognizer) {
        let aiphaZero = topView.alpha == 0
        UIView.animate(withDuration: 0.2) {
            self.topView.alpha = aiphaZero ? 1 : 0
            let height = self.topView.bounds.size.height
            self.topView.frame = CGRect(x: 0, y: aiphaZero ? 0 : -height, width: self.bounds.width, height: height)
        }
    }
    
    func reloadImage(_ model: RKFileModel) {
        
        imageModel = model
        topView.isHidden = model.fileName?.isEmpty ?? true
        dismissButton.setTitle("  \(model.fileName ?? "")", for: .normal)
        RKFilePreview.trustHost(fileUrl: model.fileUrl)
        imageView.kf.setImage(with: model.thumbUrl)
        
        if let fileSize = model.size, Double(fileSize) ?? 0 > 0 {
            sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
        } else if let url = model.fileUrl {
            sizeLabel.rk_fileSize(fileUrl: url) { [weak self] fileSize in
                self?.sizeLabel.text = "文件大小：\(fileSize.sizeFormat)"
                self?.imageModel?.size = fileSize
            }
        }

        progressView.progress = 0
        imageView.kf.setImage(with: model.fileUrl, placeholder: nil, options: [.transition(.fade(0.25)),
             .keepCurrentImageWhileLoading]) {[weak self] receivedSize, totalSize in
                 guard let self = self else { return }
                 if totalSize > 0 {
                     self.progressView.progress = CGFloat(receivedSize) / CGFloat(totalSize)
                 }
             } completionHandler: {[weak self] result in
                 guard let self = self else { return }
                 switch result {
                 case .failure(_):
                     self.progressView.progress = 0
                 case .success(_):
                     self.progressView.progress = 1.0
                 }
             }
    }
    
    //保存到相册
    @objc func downloadAction() {
        
        if let _ = imageView.image, let fileUrl = imageModel?.fileUrl {
            self.saveImage(fileUrl)
//            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
            return
        }
        guard let fileUrl = imageModel?.fileUrl, !RKDownloadManager.isDownloading(fileUrl: fileUrl) else { return }
        let sizeText = sizeLabel.text
        RKDownloadManager.downLoadFile(fileUrl: fileUrl) { [weak self] progress in
            let totalCount = progress.totalUnitCount
            let completedCount = progress.completedUnitCount
            guard let self = self, totalCount > 0 else { return }
            self.sizeLabel.text = "\(Int(Double(completedCount)/Double(totalCount) * 100))%"
            if completedCount >= totalCount {
                self.sizeLabel.text = "下载完成"
            }
        } completion: { [weak self] error, path in
            guard let self = self else { return }
            if error == nil {
                self.saveImage(URL(fileURLWithPath: path))
//                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
                
            } else {
                RKPrompt.showToast(withText: "图片保存失败", inView: self)
            }
            self.sizeLabel.text = sizeText
        }
    }
    
    private func saveImage(_ fileUrl: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: fileUrl) {
                PHPhotoLibrary.shared().performChanges {
                    let options = PHAssetResourceCreationOptions()
                    PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: options)
                } completionHandler: { (isSuccess: Bool, error: Error?) in
                    DispatchQueue.main.async {
                        RKPrompt.hidenLoading(inView: self)
                        if isSuccess {
                            RKPrompt.showToast(withText: "保存成功", inView: self)
                        } else {
                            RKPrompt.showToast(withText: "保存失败", inView: self)
                        }
                    }
                }
            }
        }
    }
    
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
            RKPrompt.showToast(withText: "图片保存失败", inView: self)
        }else{
            RKPrompt.showToast(withText: "图片保存成功", inView: self)
        }
    }
}
