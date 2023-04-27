//
//  RKVideoPlayer_VC.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/14.
//

import UIKit
import KSYMediaPlayer

public class RKVideoPlayer_VC: UIViewController {
    
    public weak var delegate: RKVideoPlayerControlDelegate?
    
    private var url: URL?
    
    private var mediaPlayer = RKMediaPlayer()
    
    private let controlView = RKVideoPlayerControlView()
    
    private var progressView: RKProgressView {
        return controlView.progressView
    }
    
    private var player: KSYMoviePlayerController {
        return mediaPlayer.player
    }
 
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIDevice.switchOrientation(orientation: .landscapeRight)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(controlView)
        controlView.delegate = self
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaPlayer.mediaPlayerClosure = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .pause:
                self.controlView.setupPlayState(play: false)
                self.delegate?.playerStateChange(false)
            case .prepared:
                self.progressView.totalTimeSeconds = Float(self.player.duration)
            case .loadState:
                self.controlView.isloading = self.player.loadState == .stalled
            case .finish:
                self.controlView.resetUIValue()
                self.seekProgress(0)
                
            case .progress:
                self.progressView.cacheProgress = Float(self.player.playableDuration/self.player.duration)
                guard !self.progressView.isDragSlider else { return }
                self.progressView.playProgress = Float(self.player.currentPlaybackTime/self.player.duration)
            }
        }
    }
    
    public func playWithURL(_ url: URL) {
        self.url = url
        mediaPlayer.play(url)
    }
    
    public func addMoreActionView(_ view: UIView) {
        controlView.stackView.addArrangedSubview(view)
    }
    
    public func seekTime(_ second: Float) {
        let duration = Float(player.duration)
        guard duration > 0 else { return }
        
        let time = max(0, min(second, duration))
        let progress = time/duration
        seekProgress(progress)
    }
    
    public func seekProgress(_ progress: Float) {
        guard player.duration > 0 else { return }
        mediaPlayer.seekProgress(progress)
        progressView.playProgress = progress
        delegate?.playerSeekProgress(progress)
    }
    
    public func switchPlayState(_ play: Bool) {
        mediaPlayer.switchPlayState(play)
        delegate?.playerStateChange(play)
    }
}


extension RKVideoPlayer_VC: RKVideoPlayerControlDelegate {
    public func playerStateChange(_ play: Bool) {
        switchPlayState(play)
    }
    
    public func playerSeekProgress(_ progress: Float) {
        seekProgress(progress)
    }
    
    public func playerQuit() {
        delegate?.playerQuit()
    }
}
