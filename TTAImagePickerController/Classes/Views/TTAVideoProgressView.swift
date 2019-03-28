//
//  TTAVideoProgressView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 05/08/2017.
//

import UIKit

protocol TTAVideoProgressViewDelegate: class {
    func videoProgressView(_ progressView: TTAVideoProgressView, seekTo percent: Double)
}

class TTAVideoProgressView: UIView {
    
    weak var delegate: TTAVideoProgressViewDelegate?
    
    fileprivate let playTimeLabel = UILabel()
    fileprivate let totalTimeLabel = UILabel()
    fileprivate let sliderView = UISlider()
    fileprivate let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
}

// MARK: - UI

extension TTAVideoProgressView {
    func setupUI() {
        func createViews() {
            layer.addSublayer(gradientLayer)
            addSubview(playTimeLabel)
            addSubview(sliderView)
            addSubview(totalTimeLabel)
        }
        
        func configViews() {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            
            playTimeLabel.text = "00:00"
            playTimeLabel.textColor = .white
            playTimeLabel.font = UIFont.systemFont(ofSize: 15)
            playTimeLabel.textAlignment = .right
            playTimeLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            totalTimeLabel.text = "00:00"
            totalTimeLabel.textColor = .white
            totalTimeLabel.font = UIFont.systemFont(ofSize: 15)
            totalTimeLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let normalImage = UIImage.image(with: .dotMark, size: UIFont.IconFontSize.dotMark, tintColor: .white)
            let highlightImage = UIImage.image(with: .dotMark, size: UIFont.IconFontSize.dotMark)
            sliderView.addTarget(self, action: #selector(didSliderChangedValue), for: .valueChanged)
            sliderView.minimumTrackTintColor = .white
            sliderView.setThumbImage(normalImage, for: .normal)
            sliderView.setThumbImage(highlightImage, for: .highlighted)
            sliderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        createViews()
        configViews()
    }
    
    func layoutViews() {
        playTimeLabel.sizeToFit()
        totalTimeLabel.sizeToFit()
        
        gradientLayer.frame = bounds
        
        playTimeLabel.frame = CGRect(x: margin(),
                                     y: (type(of: self).height() - playTimeLabel.bounds.height) / 2,
                                     width: playTimeLabel.bounds.width + 2,
                                     height: playTimeLabel.bounds.height)
        
        totalTimeLabel.frame = CGRect(x: bounds.width - margin() - totalTimeLabel.bounds.width,
                                      y: (type(of: self).height() - totalTimeLabel.bounds.height) / 2,
                                      width: totalTimeLabel.bounds.width + 2,
                                      height: totalTimeLabel.bounds.height)
        
        sliderView.frame = CGRect(x: playTimeLabel.frame.maxX + margin(),
                                  y: 0,
                                  width: totalTimeLabel.frame.minX - playTimeLabel.frame.maxX - 2 * margin(),
                                  height: bounds.height)
    }
}

// MARK: - Actions

extension TTAVideoProgressView {
    @objc func didSliderChangedValue() {
        delegate?.videoProgressView(self, seekTo: Double(sliderView.value))
    }
}

// MARK: - Public Methods

extension TTAVideoProgressView {
    func update(with videoInfo: TTAVideoProgressViewInfo) {
        playTimeLabel.text = videoInfo.currentString
        totalTimeLabel.text = videoInfo.durationString
        sliderView.setValue(videoInfo.progress, animated: true)
    }
}

// MARK: - Const

extension TTAVideoProgressView {
    static func height() -> CGFloat {
        return 34
    }
    
    func margin() -> CGFloat {
        return 8
    }
}
