//
//  RKVideoPlayerControlView.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/14.
//

import UIKit

protocol RKVideoPlayerControlDelegate: NSObjectProtocol {
    func playerStateChange(_ play: Bool)
    func seekProgress(_ progress: Float)
    func playerQuit()
}

class RKVideoPlayerControlView: UIView {
    weak var delegate: RKVideoPlayerControlDelegate?
    var progressView: RKProgressView!
    var playCenterButton: UIButton!
    var quitButton: UIButton!
    var playButton: UIButton!
    var stackView: UIStackView!
    var indicatorView: UIActivityIndicatorView!
    var isloading: Bool = false {
        didSet {
            if isloading {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        subviews.forEach { $0.removeFromSuperview() }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        
        indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.hidesWhenStopped = true
        addSubview(indicatorView)
        
        quitButton = UIButton(type: .custom)
        quitButton.setImage(Bundle.rkImage(named: "rk_player_quit"), for: .normal)
        quitButton.addTarget(self, action: #selector(quitAction), for: .touchUpInside)
        quitButton.isHidden = false
        addSubview(quitButton)
        
        playCenterButton = UIButton(type: .custom)
        playCenterButton.setImage(Bundle.rkImage(named: "rk_video_pauseBig"), for: .normal)
        playCenterButton.setImage(UIImage(), for: .selected)
        playCenterButton.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        playCenterButton.isSelected = true
        playCenterButton.isHidden = false
        addSubview(playCenterButton)

        playButton = UIButton(type: .custom)
        playButton.setImage(Bundle.rkImage(named: "rk_video_pause"), for: .normal)
        playButton.setImage(Bundle.rkImage(named: "rk_video_play"), for: .selected)
        playButton.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        playButton.isSelected = true
        playButton.isHidden = false
        addSubview(playButton)
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 14
        stackView.isHidden = false
        addSubview(stackView)
        
        progressView = RKProgressView()
        progressView.dragingSliderClosure = {[weak self] progress in
            guard let self = self else { return }
            self.delegate?.seekProgress(progress)
        }
        stackView.addArrangedSubview(progressView)
        
        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        quitButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(70)
        }
        
        playCenterButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(72)
        }
        
        playButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(stackView)
            make.width.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(playButton.snp.right).offset(0)
            make.bottom.equalToSuperview().offset(-35)
            make.right.equalToSuperview().offset(-30)
        }
        
        timerShowControl()
    }
    
    func resetUIValue() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        changeControlState(hidden: false)
        progressView.playProgress = 0
        progressView.isDragSlider = false
        playCenterButton.isSelected = false
        playButton.isSelected = false
        indicatorView.stopAnimating()
    }
    
    func setupPlayState(play: Bool) {
        changeControlState(hidden: false)
        playButton.isSelected = play
        playCenterButton.isSelected = play
        if play {
            timerShowControl()
        }
    }
    
    private func timerShowControl() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        perform(#selector(hiddenControl), with: nil, afterDelay: 3)
    }
    
    @objc private func tapAction() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenControl), object: nil)
        changeControlState(hidden: !playButton.isHidden)
        if !playButton.isHidden {
            timerShowControl()
        }
    }
    
    @objc private func hiddenControl() {
        changeControlState(hidden: true)
    }
    
    @objc private func changeControlState(hidden: Bool = true) {
        guard !progressView.isDragSlider, playButton.isSelected else { return }
        quitButton.isHidden = hidden
        playButton.isHidden = hidden
        playCenterButton.isHidden = hidden
        stackView.isHidden = hidden
    }
    
    @objc private func quitAction() {
        delegate?.playerQuit()
    }
    
    @objc private func playAction() {
        playButton.isSelected = !playButton.isSelected
        playCenterButton.isSelected = playButton.isSelected
        delegate?.playerStateChange(playButton.isSelected)
        if playButton.isSelected { timerShowControl() }
    }
}
