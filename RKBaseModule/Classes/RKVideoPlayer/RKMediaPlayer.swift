//
//  RKMediaPlayer.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/4/26.
//

import Foundation
import KSYMediaPlayer

public enum RKMediaPlayerState {
    case pause
    case prepared
    case loadState
    case finish
    case progress
}

public class RKMediaPlayer: NSObject {
    
    public lazy var player: KSYMoviePlayerController = {
        let player = KSYMoviePlayerController()
        player.shouldAutoplay = true
        player.shouldHideVideo = true
        return player
    }()
    
    public var mediaPlayerClosure: ((RKMediaPlayerState) -> Void)?
    
    public override init() {
        super.init()
        setupObservers()
    }
    
    private func setupObservers() {
        player.addObserver(self, forKeyPath: "currentPlaybackTime", options: .new, context: nil)
        registerObserver(name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish)
        registerObserver(name: NSNotification.Name.MPMoviePlayerLoadStateDidChange)
        registerObserver(name: NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered)
        registerObserver(name: NSNotification.Name.MPMoviePlayerFirstAudioFrameRendered)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func registerObserver(name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: name, object: player)
    }
    
    @objc private func didEnterBackgroundNotification() {
        if player.isPlaying() {
            player.pause()
            mediaPlayerClosure?(.pause)
        }
    }
    
    @objc private func handlePlayerNotify(notify: NSNotification) {

        if NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange == notify.name {
            mediaPlayerClosure?(.prepared)
        }
        if NSNotification.Name.MPMoviePlayerLoadStateDidChange == notify.name {
            mediaPlayerClosure?(.loadState)
        }
        if NSNotification.Name.MPMoviePlayerPlaybackDidFinish == notify.name {
            mediaPlayerClosure?(.finish)
        }
        if NSNotification.Name.MPMoviePlayerFirstAudioFrameRendered == notify.name {
            // 解决有的视频卡帧以及渲染失败bug
            player.shouldHideVideo = false
            player.seek(to: 0, accurate: true)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentPlaybackTime" {
            guard player.duration > 0 else { return }
            mediaPlayerClosure?(.progress)
        }
    }
    
    public func play(_ url: URL) {
        player.reset(false)
        player.setUrl(url)
        player.prepareToPlay()
    }
    
    public func switchPlayState(_ play: Bool) {
        let isPlaying = player.isPlaying()
        if play && !isPlaying {
            player.play()
        } else if !play && isPlaying {
            player.pause()
        }
    }
    
    public func seekTime(_ second: Float) {
        let duration = player.duration
        guard duration > 0 else { return }
        let time = max(0, min(Double(second), duration))
        player.seek(to: time, accurate: true)
    }
    
    public func seekProgress(_ progress: Float) {
        seekTime(Float(player.duration) * progress)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.removeObserver(self, forKeyPath: "currentPlaybackTime")
        player.stop()
    }
}
