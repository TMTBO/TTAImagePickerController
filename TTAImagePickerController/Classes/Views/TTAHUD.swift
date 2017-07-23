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
        public static var indicator = TTAHUDType(rawValue: 0)
        public static var tip = TTAHUDType(rawValue: 1 << 0)
        public static var progress = TTAHUDType(rawValue: 1 << 1)
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
    
    private func prepareUI(with type: TTAHUDType) {
        visualView.frame = bounds
        visualView.layer.cornerRadius = 10
        visualView.clipsToBounds = true
        addSubview(visualView)
        
        if check(type: .indicator) {
            // indicator
            indicator.center = visualView.center
            indicator.startAnimating()
            visualView.contentView.addSubview(indicator)
        }
        prepareTipLabel()
        prepareProgressView()
    }
    
    func prepareTipLabel() {
        guard check(type: .tip) else { return }
        // TipsLabel
        tipLabel.textAlignment = .center
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.adjustsFontSizeToFitWidth = true
        tipLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tipLabel.frame = CGRect(x: margin(), y: margin(), width: elementWidht(), height: tipHeight())
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
    
    func check(type: TTAHUDType) -> Bool {
        return self.type.contains(type)
    }
}

extension TTAHUD {
    
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
