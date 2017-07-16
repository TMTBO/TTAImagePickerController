//
//  TTAHUD.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 16/07/2017.
//

import UIKit

class TTAHUD: UIView {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    init() {
        super.init(frame: CGRect(x: x(), y: y(), width: widthAndHeight(), height: widthAndHeight()))
        let blur = UIBlurEffect(style: .dark)
        let visualView = UIVisualEffectView(effect: blur)
        visualView.frame = bounds
        visualView.layer.cornerRadius = 10
        visualView.clipsToBounds = true
        addSubview(visualView)
        
        indicator.center = visualView.center
        indicator.startAnimating()
        visualView.contentView.addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TTAHUD {
    
    static func showIndicator() -> TTAHUD {
        let hud = TTAHUD()
        UIApplication.shared.keyWindow?.addSubview(hud)
        return hud
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
    func widthAndHeight() -> CGFloat {
        return min(UIScreen.main.bounds.width / 3, 150)
    }
    
    func x() -> CGFloat {
        return (UIScreen.main.bounds.width - widthAndHeight()) / 2
    }
    
    func y() -> CGFloat {
        return (UIScreen.main.bounds.height - widthAndHeight()) / 2
    }
}
