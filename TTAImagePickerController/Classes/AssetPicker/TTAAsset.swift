//
//  TTAAsset.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

public class TTAAsset {
    
    var originalAsset: PHAsset
    var assetID: String {
        return originalAsset.localIdentifier
    }
    
    var thumbnail: UIImage?
    var originalImage: UIImage?
    
    init(originalAsset: PHAsset) {
        self.originalAsset = originalAsset
    }
}

// MARK: - Request image

extension TTAAsset {
    
    func requestThumbnail(for size: CGSize, resultHandler: ((UIImage?) -> Void)?) {
        if thumbnail != nil { resultHandler?(thumbnail); return }
        return request(for: originalAsset, size: size, options: nil) { [weak self] (image, _) in
            self?.thumbnail = image
            resultHandler?(image)
        }
    }
    
    func requestOriginalImage(isSync: Bool, resultHandler: ((UIImage?) -> Void)?) {
        if originalImage != nil { resultHandler?(originalImage); return }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = isSync
        
        request(for: originalAsset, size: UIScreen.main.bounds.size, options: options) { [weak self] (image, _) in
            self?.originalImage = image
            resultHandler?(image)
        }
    }
    
    private func request(for asset: PHAsset,
                         size: CGSize,
                         contentMode: PHImageContentMode? = TTAImagePickerManager.AssetManagerConst.assetMode,
                         options: PHImageRequestOptions?,
                         resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        TTAImagePickerManager.fetchImage(for: self, size: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
        
    }
}
