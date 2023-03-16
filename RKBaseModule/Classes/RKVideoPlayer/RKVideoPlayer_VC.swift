//
//  RKVideoPlayer_VC.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/14.
//

import UIKit
import KSYMediaPlayer

public protocol RKVideoPlayerDelegate {
    func playerQuit()
    func playerStateChange(_ play: Bool)
}

public class RKVideoPlayer_VC: UIViewController {
    
    public var delegate: RKVideoPlayerDelegate?
    
    private var url: URL?
    
    private let controlView = RKVideoPlayerControlView()
    
    private var progressView: RKProgressView {
        return controlView.progressView
    }
    
    private lazy var mediaPlayer: KSYMoviePlayerController = {
        let player = KSYMoviePlayerController()
        player.shouldAutoplay = true
        return player
    }()
 
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIDevice.switchOrientation(orientation: .landscapeRight)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(mediaPlayer.view)
        mediaPlayer.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(controlView)
        controlView.delegate = self
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupObservers()
    }
    
    private func setupObservers() {
        mediaPlayer.addObserver(self, forKeyPath: "currentPlaybackTime", options: .new, context: nil)
        mediaPlayer.addObserver(self, forKeyPath: "playableDuration", options: .new, context: nil)
        registerObserver(name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish)
        registerObserver(name: NSNotification.Name.MPMoviePlayerLoadStateDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func registerObserver(name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: name, object: mediaPlayer)
    }
    
    @objc private func didEnterBackgroundNotification() {
        if mediaPlayer.isPlaying() {
            mediaPlayer.pause()
            controlView.setupPlayState(play: true)
        }
    }
    
    private var reloading = false
    @objc private func handlePlayerNotify(notify: NSNotification) {

        if NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange == notify.name {
            progressView.totalTimeSeconds = Float(mediaPlayer.duration)
            reloading = false
        }
        if NSNotification.Name.MPMoviePlayerLoadStateDidChange ==  notify.name {
            controlView.isloading = mediaPlayer.loadState == .stalled
        }
        if NSNotification.Name.MPMoviePlayerPlaybackDidFinish == notify.name {
            controlView.resetUIValue()
            reloading = true
        }
        if NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered == notify.name {
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentPlaybackTime" {
            guard !reloading, !progressView.isDragSlider, mediaPlayer.duration > 0 else { return }
            progressView.playProgress = Float(mediaPlayer.currentPlaybackTime/mediaPlayer.duration)
            
        } else if keyPath == "playableDuration" {
            guard mediaPlayer.duration > 0 else { progressView.cacheProgress = 0; return }
            progressView.cacheProgress = Float(mediaPlayer.playableDuration/mediaPlayer.duration)
        }
    }
    
    public func playWithURL(url: URL) {
        self.url = url
        mediaPlayer.setUrl(url)
        mediaPlayer.prepareToPlay()
    }
    
    public func addMoreActionView(view: UIView) {
        controlView.stackView.addArrangedSubview(view)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer.removeObserver(self, forKeyPath: "currentPlaybackTime")
        mediaPlayer.stop()
    }
}


extension RKVideoPlayer_VC: RKVideoPlayerControlDelegate {
    internal func playerStateChange(_ play: Bool) {
        let isPlaying = mediaPlayer.isPlaying()
        if play && !isPlaying {
            if reloading, let url = url {
                mediaPlayer.reload(url)
            } else {
                mediaPlayer.play()
            }
        } else if !play && isPlaying {
            mediaPlayer.pause()
        }
        delegate?.playerStateChange(play)
    }
    
    internal func seekProgress(_ progress: Float) {
        let time = mediaPlayer.duration * Double(progress)
        mediaPlayer.seek(to: time, accurate: true)
    }
    
    internal func playerQuit() {
        delegate?.playerQuit()
    }
}
