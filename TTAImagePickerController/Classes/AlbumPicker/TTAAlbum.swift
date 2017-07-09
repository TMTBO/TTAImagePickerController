//
//  TTAAlbum.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

struct TTAAlbum {
    
    var original: PHAssetCollection!
    var assets: PHFetchResult<PHAsset> = PHFetchResult()
}

extension TTAAlbum {
    func albumID() -> String {
        return original.localIdentifier
    }
    
    func name() -> String? {
        return original.localizedTitle
    }
    
    func assetCount() -> Int {
        return assets.count
    }
    
    func thumbnailAsset() -> PHAsset? {
        return asset(at: 0)
    }
}

extension TTAAlbum {
    
    func asset(at index: Int) -> PHAsset? {
        if index >= assets.count || index < 0 { return nil }
        return assets[index]
    }
    
    func index(for asset: PHAsset) -> Int {
        return assets.index(of: asset)
    }
    
    func isContain(_ asset: PHAsset) -> Bool {
        return assets.contains(asset)
    }
}

// MARK: - Request image

extension TTAAlbum {
    
    func requestThumbnail(with index: Int, size: CGSize, progressHandler: PHAssetImageProgressHandler? = nil, resultHandler: ((UIImage?) -> Void)?) {
        let requestAsset = asset(at: index)
        request(for: requestAsset, size: size, options: TTAImagePickerManager.defaultOptions(), progressHandler: progressHandler) { (image, _) in
            resultHandler?(image)
        }
    }
    
    private func request(for asset: PHAsset?,
                         size: CGSize,
                         options: PHImageRequestOptions,
                         progressHandler: PHAssetImageProgressHandler?,
                         resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
            TTAImagePickerManager.fetchImage(for: asset, size: size, options: options, progressHandler: progressHandler, resultHandler: resultHandler)
    }
}
