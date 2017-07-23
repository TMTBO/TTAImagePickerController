//
//  Bundle+TTAImagePickerController.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 23/07/2017.
//

import Foundation

extension Bundle {
    
    class func imagePickerBundle() -> Bundle {
        guard let path = Bundle(for: TTAImagePickerController.self).path(forResource: "TTAImagePickerController", ofType: "bundle"),
            let bundle = Bundle(path: path) else {
                fatalError("Can NOT find the Bundle, named: TTAImagePickerController.bundle")
        }
        return bundle
    }
    
    class func localizedString(for key: String, value: String? = nil) -> String {
        let language: String
        if let preferredLanguage = Locale.preferredLanguages.first {
            if preferredLanguage.hasPrefix("en") {
                language = "en"
            } else if preferredLanguage.hasPrefix("zh") {
                language = "zh"
            } else {
                language = "en"
            }
        } else {
            language = "en"
        }
        guard let path = imagePickerBundle().path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
                fatalError("Can NOT find the \(language).lproj")
        }
        let value = bundle.localizedString(forKey: key , value: value, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
}
