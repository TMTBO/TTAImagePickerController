//
//  UIView+Animations.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

extension UIView {
    func selectItemSpringAnimation() {
        transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [weak self] in
            guard let `self` = self else { return }
            self.transform = .identity
            }, completion: nil)
    }
}
