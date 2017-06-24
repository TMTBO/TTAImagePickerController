//
//  UIFont+IconFont.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 18/06/2017.
//

import UIKit

extension UIFont {
    
    struct AssociatedKey {
        static var iconfontName = "iconfontName"
    }
    
    static var iconfontName: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.iconfontName) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.iconfontName, newValue as Any, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    static func registerFont(with url: URL, fontName: String) {
        assert(FileManager.default.fileExists(atPath: url.path), "Font file doesn't exist")
        guard let fontDataProider = CGDataProvider(url: url as CFURL),
            let newFont = CGFont(fontDataProider) else { return }
        CTFontManagerRegisterGraphicsFont(newFont, nil)
        iconfontName = fontName
    }
    
    static func iconfont(size: CGFloat) -> UIFont? {
        return UIFont(name: UIFont.iconfontName, size: size)
    }
}


// MARK: - IconFont

extension UIFont {
    
    enum IconFont: String {
        case selectMark = "\u{e70d}"
    }
    
    struct IconFontSize {
        static let assetSelectMark: CGFloat = 15
    }
}
