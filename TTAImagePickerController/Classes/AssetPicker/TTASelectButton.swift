//
//  TTASelectButton.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 18/06/2017.
//

import UIKit

class TTASelectButton: UIButton {
    
    enum TTASelectButtonState {
        case `default`;
        case selected
    }
    
    let bgView = UIView()
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor? {
        didSet {
            bgView.backgroundColor = bgView.backgroundColor == .clear ? .clear : selectItemTintColor
        }
    }
    
    var selectState: TTASelectButtonState = .default {
        didSet {
            switch selectState {
            case .default:
                _unselectItem()
            case .selected:
                _selectItem()
            }
        }
    }
    
    fileprivate let circleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI(); 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutViews()
        bgView.corner(roundedRect: bounds, cornerRadius: bounds.width / 2)
    }
}

// MARK: - UI

extension TTASelectButton {
    
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
    }
    
    func _createViews() {
        addSubview(bgView)
    }
    
    func _configViews() {
        titleLabel?.textAlignment = .center
        adjustsImageWhenHighlighted = false
        backgroundColor = .clear
        
        bgView.isUserInteractionEnabled = false
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _shapLayer()
        _unselectItem()
    }
    
    func _layoutViews() {
        bgView.bounds = frame
        titleLabel?.frame = bounds
        circleLayer.frame = bounds
    }
    
    func _shapLayer() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 13, y: 13), radius: 13 - 1, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        path.lineWidth = 1
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        layer.addSublayer(circleLayer)
    }
}

// MARK: - Select

extension TTASelectButton {
    
    func _selectItem() {
        circleLayer.isHidden = true
        bgView.backgroundColor = selectItemTintColor ?? UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
        _selectAnimation()
    }
    
    func _unselectItem() {
        setTitle(UIFont.IconFont.selectMark.rawValue, for: .normal)
        titleLabel?.font = UIFont.iconfont(size: UIFont.IconFontSize.assetSelectMark)
        bgView.backgroundColor = .clear
        circleLayer.isHidden = false
    }
    
    func _selectAnimation() {
        bgView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [weak self] in
            guard let `self` = self else { return }
            self.bgView.transform = .identity
        }, completion: nil)
    }
}
