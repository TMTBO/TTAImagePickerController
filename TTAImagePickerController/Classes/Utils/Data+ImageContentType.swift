//
//  Data+ImageContentType.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 30/07/2017.
//

import Foundation

extension Data {
    
    var imageContentType: UIImage.ImageContentType {
        var typeValue: UInt8 = 0
        copyBytes(to: &typeValue, count: 1)
        
        let type: UIImage.ImageContentType
        switch typeValue {
        case 0xFF:
            type = .jpeg
        case 0x89:
            type = .png
        case 0x47:
            type = .gif
        case 0x49:
            fallthrough
        case 0x4D:
            type = .tiff
        case 0x52:
            type = isValidWEBP
        default:
            type = .unknown
        }
        return type
    }
    
    private var isValidWEBP: UIImage.ImageContentType {
        guard count >= 12 else { return .unknown }
        guard let typeString = String(data: subdata(in: 0..<12), encoding: .ascii),
            typeString.hasPrefix("RIFF") && typeString.hasSuffix("WEBP") else { return .unknown }
        return .webp
    }
}
