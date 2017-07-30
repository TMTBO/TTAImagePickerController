//
//  TTAAssetVideoComponentView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 29/07/2017.
//

import UIKit

class TTAAssetVideoComponentView: UIView {

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

fileprivate extension TTAAssetVideoComponentView {
    func setupUI() {
        func configViews() {
            iconLabel.text = UIFont.IconFont.videoMark.rawValue
            iconLabel.font = UIFont.iconfont(size: UIFont.IconFontSize.videoMark)
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
                                 width: UIFont.IconFontSize.videoMark,
                                 height: type(of: self).height())
        timeLabel.frame = CGRect(x: iconLabel.frame.maxX + type(of: self).sideMargin(),
                                 y: 0,
                                 width: bounds.width - iconLabel.frame.maxX - 2 * type(of: self).sideMargin(),
                                 height: type(of: self).height())
        gradientLayer.frame = self.bounds
    }
}

// MARK: - Public Methods

extension TTAAssetVideoComponentView {
    func update(with videoInfo: TTAAssetVideoInfo) {
        timeLabel.text = videoInfo.timeLength
    }
}

// MARK: - Const

extension TTAAssetVideoComponentView {
    static func height() -> CGFloat {
        return 17
    }
    
    fileprivate static func sideMargin() -> CGFloat {
        return 5
    }
}
