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
            return objc_getAssociatedObject(self, &AssociatedKey.iconfontName) as? String ?? "iconfont"
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.iconfontName, newValue as Any, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    static func registerFont(with url: URL, fontName: String) {
        assert(FileManager.default.fileExists(atPath: url.path), "Font file doesn't exist")
        guard let fontDataProider = CGDataProvider(url: url as CFURL) else { return }
        let newFont = CGFont(fontDataProider)
        CTFontManagerRegisterGraphicsFont(newFont, nil)
        iconfontName = fontName
    }
    
    static func iconfont(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: UIFont.iconfontName, size: size) else { fatalError("Can NOT load the font,maybe the IconFont Name NOT registe") }
        return font
    }
}


// MARK: - IconFont

extension UIFont {
    
    enum IconFont: String {
        case selectMark = "\u{e70d}"
        case backMark = "\u{e6fa}"
        case warningMark = "\u{e62a}"
        case photoMark = "\u{e605}"
        case cameraMark = "\u{e623}"
        case videoMark = "\u{e628}"
    }
    
    struct IconFontSize {
        static let assetSelectMark: CGFloat = 15
        static let backMark: CGFloat = 25
        static let warningMark: CGFloat = 20
        static let photoMark: CGFloat = 80
        static let cameraMark: CGFloat = 30
        static let videoMark: CGFloat = 20
    }
}
