//
//  TTAAsset.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

public  struct TTAAsset {
    
    var originalAsset: PHAsset
    var assetID: String! {
        return originalAsset.localIdentifier
    }
    
    var thumbnail: UIImage?
    var originalImage: UIImage?
    
    var requestID: PHImageRequestID?
    
    init(originalAsset: PHAsset) {
        self.originalAsset = originalAsset
    }

}

// MARK: - Request image

extension TTAAsset {
    
    mutating func requestThumbnail(for size: CGSize, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        request(for: originalAsset, size: size, options: TTAImagePickerManager.AssetManagerConst.assetRequestOptions, resultHandler: resultHandler)
    }
    
    mutating func requestOriginalImage(isSync: Bool, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = isSync
        var copy = self
        request(for: originalAsset, size: UIScreen.main.bounds.size, options: options) { (image, info) in
            copy.originalImage = image
            resultHandler(image, info)
        }
        self = copy
    }
    
    mutating func request(for asset: PHAsset,
                          size: CGSize,
                          contentMode: PHImageContentMode? = TTAImagePickerManager.AssetManagerConst.assetMode,
                          options: PHImageRequestOptions?,
                          resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        var copy = self
        let requestID = TTAImagePickerManager
            .fetchImage(for: originalAsset,
                        size: size.toPixel(),
                        contentMode: contentMode,
                        options: options) { (image, info) in
                            guard let isDegraded = info?["PHImageResultIsDegradedKey"] as AnyObject?
                                , !(image == nil && !isDegraded.boolValue) else { return }
                            copy.thumbnail = image
        }
        self = copy
        self.requestID = requestID
    }
}
