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
        case photoMark      =    "\u{e605}"
        case cameraMark     =    "\u{e606}"
        case videoMark      =    "\u{e607}"
        case warningMark    =    "\u{e608}"
        case pauseMark      =    "\u{e609}"
        case backMark       =    "\u{e60a}"
        case selectMark     =    "\u{e60b}"
        case playMark       =    "\u{e60c}"
        case dotMark        =    "\u{e60d}"
        case gifMark        =    "\u{e60e}"
        case trashMark      =    "\u{e60f}"
    }
    
    struct IconFontSize {
        static let assetSelectMark: CGFloat = 15
        static let backMark: CGFloat = 25
        static let warningMark: CGFloat = 20
        static let photoMark: CGFloat = 80
        static let cameraMark: CGFloat = 50
        static let videoAndGifMark: CGFloat = 20
        static let playMark: CGFloat = 60
        static let dotMark: CGFloat = 20
        static let trashMark: CGFloat = 28
    }
}
