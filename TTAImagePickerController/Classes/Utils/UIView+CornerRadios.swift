//
//  UIView+CornerRadios.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 18/06/2017.
//

import UIKit

extension UIView {
    
    func corner(with radius: CGFloat) {
        corner(roundedRect: bounds, cornerRadius: radius)
    }
    
    func corner(roundedRect rect: CGRect, corners: UIRectCorner = UIRectCorner.allCorners, cornerRadius: CGFloat) {
        corner(roundedRect: rect, corners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    func corner(roundedRect rect: CGRect, corners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
