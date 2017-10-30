//
//  CGSize+Pixel.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 18/06/2017.
//

import UIKit

extension CGSize {
    func toPixel() -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
