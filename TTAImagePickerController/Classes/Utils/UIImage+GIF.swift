//
//  UIImage+GIF.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 30/07/2017.
//

import UIKit

extension Data {
    var animatedGIF: UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else { return nil }
        let imageCount = CGImageSourceGetCount(imageSource)
        
        let animatedImage: UIImage?
        if imageCount <= 1 {
            animatedImage = UIImage(data: self, scale: UIScreen.main.scale)
        } else {
            var images: [UIImage] = []
            var duration = 0.0
            for index in 0..<imageCount {
                let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
                if image == nil { continue }
                duration += UIImage.frameDuration(at: index, source: imageSource)
                images.append(UIImage(cgImage: image!, scale: UIScreen.main.scale, orientation: .up))
            }
            if duration == 0 {
                duration = Double((1 / 10) * imageCount)
            }
            
            animatedImage = UIImage.animatedImage(with: images, duration: duration)
        }
        return animatedImage
    }
}

extension UIImage {
    
    enum ImageContentType: String {
        case unknown = "image/unknown"
        case jpeg = "image/jpeg"
        case png = "image/png"
        case gif = "image/gif"
        case tiff = "image/tiff"
        case webp = "image/webp"
    }
    
    static func imageContentType(for data: Data) -> ImageContentType {
        return data.imageContentType
    }
    
    func animatedGIF(with data: Data) -> UIImage? {
        return data.animatedGIF
    }
    
    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        var frameDuration = 0.1
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: [String: Double]],
            let gifProperties = frameProperties[String(kCGImagePropertyGIFDictionary)] else { return frameDuration }
        
        if let delayTimeUnclampedProp = gifProperties[String(kCGImagePropertyGIFUnclampedDelayTime)] {
            frameDuration = delayTimeUnclampedProp
        } else {
            let delayTimeProp = gifProperties[String(kCGImagePropertyGIFDelayTime)]
            frameDuration = delayTimeProp ?? frameDuration
        }
        
        if frameDuration < 0.011 {
            frameDuration = 0.1
        }
        
        return frameDuration
    }
}
