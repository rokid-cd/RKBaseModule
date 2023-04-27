//
//  RKProgressView.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/3/14.
//

import UIKit

class ARIMSlider: UISlider {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let bounds: CGRect = self.bounds.insetBy(dx: -20, dy: -20)
        return bounds.contains(point)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: 4)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let thumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        if value == 0 {
            return CGRect(x: 0, y: thumbRect.origin.y, width: thumbRect.size.width, height: thumbRect.size.height)
        } else if value == 1 {
            return CGRect(x: rect.size.width - thumbRect.size.width, y: thumbRect.origin.y, width: thumbRect.size.width, height: thumbRect.size.height)
        }
        return thumbRect
    }
}

public class RKProgressView: UIView {
    
    public var isDragSlider = false
    public var dragingSliderClosure: ((Float)->Void)?
    public var totalTimeSeconds: Float = 0 {
        didSet {
            updateTime(lab: playedTimeLabel, time: playProgress * totalTimeSeconds)
            updateTime(lab: totalTimeLabel, time: totalTimeSeconds)
            playedTimeLabel.snp.updateConstraints { make in
                make.width.equalTo((totalTimeSeconds > 60 * 60) ? 72 : 46)
            }
            superview?.layoutIfNeeded()
        }
    }
    public var cacheProgress: Float = 0 {
        didSet {
            progressView.setProgress(cacheProgress, animated: true)
        }
    }
    public var playProgress: Float = 0 {
        didSet {
            slider.setValue(playProgress, animated: true)
            updateTime(lab: playedTimeLabel, time: playProgress * totalTimeSeconds)
        }
    }
    public var timeShadow: Bool = true
    
    public var timeColor: UIColor? {
        didSet {
            playedTimeLabel.textColor = timeColor
            totalTimeLabel.textColor = timeColor
        }
    }
    
    public var trackTintColor: UIColor? {
        didSet {
            slider.maximumTrackTintColor = trackTintColor ?? .clear
        }
    }
    
    private var slider: ARIMSlider!
    
    private var progressView: UIProgressView!
    
    private var playedTimeLabel: UILabel!
    
    private var totalTimeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        progressView = UIProgressView()
        progressView.trackTintColor = .white.withAlphaComponent(0.6)
        progressView.progressTintColor = .black.withAlphaComponent(0.2)
        addSubview(progressView)
        
        slider = ARIMSlider()
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = UIColor(hex: 0x194BFB)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.setThumbImage(Bundle.rkImage(named: "rk_video_thumb")?.cicleImage(), for: .normal)
        slider.addTarget(self, action: #selector(sliderBeginAction), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderChangeAction), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidEndAction), for: .touchUpInside)
        addSubview(slider)
        
        playedTimeLabel = UILabel()
        playedTimeLabel.textColor = .white
        playedTimeLabel.textAlignment = .center
        playedTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        playedTimeLabel.text = "00:00"
        addSubview(playedTimeLabel)
        
        totalTimeLabel = UILabel()
        totalTimeLabel.textColor = .white
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        totalTimeLabel.text = "00:00"
        addSubview(totalTimeLabel)
        
        playedTimeLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(46)
            make.height.equalTo(22)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.height.equalTo(playedTimeLabel)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.equalTo(playedTimeLabel.snp.right).offset(8)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
        
        slider.snp.makeConstraints { make in
            make.left.right.centerY.height.equalTo(progressView)
        }
    }
    
    private func updateTime(lab: UILabel, time: Float) {
        let timeText = formatTime(time: time)
        if timeShadow {
            lab.attributedText = attributedFormatTime(text: timeText)
        } else {
            lab.text = timeText
        }
    }
    
    private func formatTime(time: Float) -> String {
        let timeH = Int(ceil(time)) / (60 * 60)
        let timeS = Int(ceil(time)) % 60
        var text = ""
        if totalTimeSeconds > 60 * 60 {
            let timeM = Int(ceil(time)) / 60 % 60
            text = String(format:"%0.2d:%0.2d:%0.2d", timeH, timeM, timeS)
        } else {
            let timeM = Int(ceil(time)) / 60
            text = String(format:"%0.2d:%0.2d", timeM, timeS)
        }
        return text
    }
    
    private func attributedFormatTime(text: String) -> NSMutableAttributedString {
        
        let att = NSMutableAttributedString(string: text)
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSizeMake(0, 2)
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.25)
        att.addAttribute(NSAttributedString.Key.shadow, value: shadow, range: NSMakeRange(0,att.length))
        return att
    }

    @objc private func sliderBeginAction() {
        isDragSlider = true
    }
    
    @objc private func sliderChangeAction() {
        guard totalTimeSeconds > 0 else { return }
        updateTime(lab: playedTimeLabel, time: totalTimeSeconds * slider.value)
    }
    
    @objc private func sliderDidEndAction() {
        isDragSlider = false
        dragingSliderClosure?(slider.value)
    }
}
