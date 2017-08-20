//
//  TTAHUD.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 16/07/2017.
//

import UIKit

class TTAHUD: UIView {
    
    public struct TTAHUDType : OptionSet {
        let rawValue: UInt
        public static var indicator = TTAHUDType(rawValue: 1 << 0)
        public static var tip = TTAHUDType(rawValue: 1 << 1)
        public static var progress = TTAHUDType(rawValue: 1 << 2)
    }
    
    let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    fileprivate let progressView = UIProgressView(progressViewStyle: .default)
    fileprivate let tipLabel = UILabel()
    
    fileprivate var type = TTAHUDType.indicator
    
    init(with type: TTAHUDType) {
        super.init(frame: CGRect(x: type(of: self).x(), y: type(of: self).y(), width: type(of: self).widthAndHeight(), height: type(of: self).widthAndHeight()))
        self.type = type
        prepareUI(with: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTipLabel()
    }
    
    private func prepareUI(with type: TTAHUDType) {
        visualView.frame = bounds
        visualView.layer.cornerRadius = 10
        visualView.clipsToBounds = true
        visualView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(visualView)
        
        prepareIndicator()
        prepareTipLabel()
        prepareProgressView()
    }
    
    func prepareIndicator() {
        guard check(type: .indicator) else { return }
        // indicator
        indicator.center = visualView.center
        indicator.startAnimating()
        visualView.contentView.addSubview(indicator)
    }
    
    func prepareTipLabel() {
        guard check(type: .tip) else { return }
        // TipsLabel
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.textColor = .white
        tipLabel.adjustsFontSizeToFitWidth = true
        visualView.contentView.addSubview(tipLabel)
    }
    
    func prepareProgressView() {
        guard check(type: .progress) else { return }
        // progressView
        progressView.progressTintColor = .white
        progressView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        progressView.frame = CGRect(x: margin(), y: bounds.height - margin() - progressHeight(), width: elementWidht(), height: progressHeight())
        visualView.contentView.addSubview(progressView)
    }
}

// MARK: - Layout

extension TTAHUD {
    func layoutTipLabel() {
        let isOnly = check(only: .tip)
        if isOnly {
            tipLabel.font = UIFont.systemFont(ofSize: 25)
            tipLabel.sizeToFit()
            let rect = tipLabel.frame
            let width = min(rect.width, maxWidth())
            let height = min(rect.height, maxHeight())
            tipLabel.frame = CGRect(x: margin(), y: margin(), width: width, height: height)
            frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: (UIScreen.main.bounds.height - height) / 2, width: width + 2 * margin(), height: height + 2 * margin())
        } else {
            tipLabel.font = UIFont.systemFont(ofSize: 15)
            tipLabel.frame = CGRect(x: margin(), y: margin(), width: elementWidht(), height: tipHeight())
        }
    }
}

// MARK: - Check

extension TTAHUD {
    func check(type: TTAHUDType) -> Bool {
        return self.type.contains(type)
    }
    
    func check(only type: TTAHUDType) -> Bool {
        return self.type.symmetricDifference(type) == TTAHUDType(rawValue: 0)
    }
}

// MARK: - Public Methods

extension TTAHUD {
    
    static func showTip(_ tip: String, delay: TimeInterval = 1) {
        let hud = TTAHUD(with: TTAHUDType.tip)
        hud.tipLabel.text = tip;
        UIApplication.shared.keyWindow?.addSubview(hud)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            hud.dimiss()
        }
    }
    
    static func showIndicator(with type: TTAHUDType, tip: String = Bundle.localizedString(for: "Loading")) -> TTAHUD {
        let hud = TTAHUD(with: type)
        hud.tipLabel.text = tip;
        UIApplication.shared.keyWindow?.addSubview(hud)
        return hud
    }
    
    func updateTip(_ tip: String) {
        if tipLabel.superview == nil {
            prepareTipLabel()
            type.formUnion(.tip)
        }
        tipLabel.text = tip
    }
    
    func updateProgress(_ progress: Double) {
        if progressView.superview == nil {
            prepareProgressView()
            type.formUnion(.progress)
        }
        progressView.progress = Float(progress)
    }
    
    static func dimiss(_ hud: TTAHUD) {
        hud.dimiss()
    }
    
    func dimiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }) { (_) in
            self.indicator.stopAnimating()
            self.removeFromSuperview()
        }
    }
    
}

// MARK: - Const

extension TTAHUD {
    func margin() -> CGFloat {
        return 5
    }
    func tipHeight() -> CGFloat {
        return 20
    }
    func progressHeight() -> CGFloat {
        return 5
    }
    func elementWidht() -> CGFloat {
        return bounds.width - 2 * margin()
    }
    func maxWidth() -> CGFloat {
        return UIScreen.main.bounds.width - 8 * margin()
    }
    func maxHeight() -> CGFloat {
        return type(of: self).widthAndHeight()
    }
    static func widthAndHeight() -> CGFloat {
        return min(UIScreen.main.bounds.width / 3, 150)
    }
    static func x() -> CGFloat {
        return (UIScreen.main.bounds.width - widthAndHeight()) / 2
    }
    static func y() -> CGFloat {
        return (UIScreen.main.bounds.height - widthAndHeight()) / 2
    }
}
