//
//  UIImage+IconFont.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 25/06/2017.
//

import UIKit

extension UIImage {
    
    static func image(with iconfont: UIFont.IconFont, size: CGFloat = 15, tintColor: UIColor = .lightGray, backgroundColor: UIColor = .clear) -> UIImage {
        let font = UIFont.iconfont(size: size)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: tintColor,
                          NSAttributedString.Key.backgroundColor: backgroundColor,
                          NSAttributedString.Key.paragraphStyle: style]
        
        let attString = NSAttributedString(string: iconfont.rawValue, attributes: attributes)
        
        let ctx = NSStringDrawingContext()
        var textRect = attString.boundingRect(with: CGSize(width: font.pointSize, height: font.pointSize), options: .usesLineFragmentOrigin, context: ctx)
        textRect.origin = .zero
        
        UIGraphicsBeginImageContextWithOptions(textRect.size, false, UIScreen.main.scale)
        attString.draw(in: textRect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("Can NOT generate the image with the IconFont: \(iconfont)") }
        return image
    }
    
    static func image(with iconfont: UIFont.IconFont, in size: CGSize, tintColor: UIColor = .lightGray, backgroundColor: UIColor = .clear, cornerRadius: CGFloat = 0) -> UIImage {
        let realSize = min(size.width, size.height)
        let font = UIFont.iconfont(size: realSize)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: tintColor,
                          NSAttributedString.Key.backgroundColor: backgroundColor,
                          NSAttributedString.Key.paragraphStyle: style]
        
        let attString = NSAttributedString(string: iconfont.rawValue, attributes: attributes)
        
        let ctx = NSStringDrawingContext()
        var textRect = attString.boundingRect(with: CGSize(width: font.pointSize, height: font.pointSize), options: .usesLineFragmentOrigin, context: ctx)
        textRect.origin = .zero
        
        UIGraphicsBeginImageContextWithOptions(textRect.size, false, UIScreen.main.scale)
        
        let pathRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path: UIBezierPath
        if cornerRadius > 0 {
            path = UIBezierPath(roundedRect: pathRect, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath(rect: pathRect)
        }
        backgroundColor.setFill()
        path.fill()
        
        attString.draw(in: textRect.offsetBy(dx: (size.width - textRect.width) / 2, dy: (size.height - textRect.height) / 2))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("Can NOT generate the image with the IconFont: \(iconfont)") }
        return image
    }
}
