//
//  TTAAssetVideoComponentView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 29/07/2017.
//

import UIKit

class TTAAssetComponentView: UIView {

    fileprivate let iconLabel = UILabel()
    fileprivate let timeLabel = UILabel()
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

fileprivate extension TTAAssetComponentView {
    func setupUI() {
        func configViews() {
            iconLabel.text = UIFont.IconFont.videoMark.rawValue
            iconLabel.font = UIFont.iconfont(size: UIFont.IconFontSize.videoAndGifMark)
            iconLabel.textColor = .white
            iconLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            timeLabel.font = UIFont.systemFont(ofSize: 11)
            timeLabel.textColor = .white
            timeLabel.textAlignment = .right
            timeLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            gradientLayer.startPoint = .zero
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(0.7).cgColor
            ]
            
            layer.addSublayer(gradientLayer)
            addSubview(iconLabel)
            addSubview(timeLabel)
        }
        configViews()
    }
    
    func layoutViews() {
        iconLabel.frame = CGRect(x: type(of: self).sideMargin(),
                                 y: 0,
                                 width: UIFont.IconFontSize.videoAndGifMark,
                                 height: type(of: self).height())
        timeLabel.frame = CGRect(x: iconLabel.frame.maxX + type(of: self).sideMargin(),
                                 y: 0,
                                 width: bounds.width - iconLabel.frame.maxX - 2 * type(of: self).sideMargin(),
                                 height: type(of: self).height())
        gradientLayer.frame = self.bounds
    }
}

// MARK: - Update Views

fileprivate extension TTAAssetComponentView {
    func updateViews(iconfont: UIFont.IconFont, timeString: String?) {
        iconLabel.text = iconfont.rawValue
        timeLabel.text = timeString
    }
}

// MARK: - Public Methods

extension TTAAssetComponentView {
    func update(with videoInfo: TTAAssetVideoInfo) {
        updateViews(iconfont: .videoMark, timeString: videoInfo.timeLength)
    }
    
    func update(isGif: Bool) {
        updateViews(iconfont: .gifMark, timeString: nil)
    }
}

// MARK: - Const

extension TTAAssetComponentView {
    static func height() -> CGFloat {
        return 17
    }
    
    fileprivate static func sideMargin() -> CGFloat {
        return 2
    }
}
