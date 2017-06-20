//
//  TTAImagePickerManager.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

class TTAImagePickerManager {
    
    static let shared = TTAImagePickerManager()
    
    /// All asset collections
    let assetCollections = TTAImagePickerManager.fetchAssetCollections()
    
    /// The number of the image picker pre row, default is 4
    var columnNum = 4
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `.green`
    var selectItemTintColor: UIColor?
}

// MARK: - TTAAssetCollection

extension TTAImagePickerManager {
    
    struct AssetCollectionManagerConst {
        static let assetCollectionSize = CGSize(width: 80, height: 80)
        static let assetCollectionContentMode = PHImageContentMode.aspectFill
        static let assetCollectionRequestOptions = _defaultOptions()
        
        private static func _defaultOptions() -> PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.version = .current
            return options
        }
    }
    
    static func fetchAssetCollections() -> [TTAAssetCollection] {
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        guard fetchResult.count > 0 else { return [TTAAssetCollection]() }
        
        var assetCollections: [TTAAssetCollection] = []
        
        fetchResult.enumerateObjects(options: .concurrent) { (assetCollection, _, _) in
            let assetResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            guard assetResult.count > 0 else { return }
            
            var assetCollectionModel = TTAAssetCollection()
            assetCollectionModel.originalCollection = assetCollection
            assetCollectionModel.assets = assetResult
            assetCollectionModel.assetCollectionID = assetCollection.localIdentifier
            assetCollectionModel.assetCollectionName = assetCollection.localizedTitle
            assetCollectionModel.assetCount = assetResult.count
            
            let thumbnailAsset = TTAAsset(originalAsset: assetResult.firstObject!)
            assetCollectionModel.thumbnailAsset = thumbnailAsset
            
            assetCollections.append(assetCollectionModel)
        }
        assetCollections.sort { (collection1, collection2) -> Bool in
            return collection1.assetCollectionName < collection2.assetCollectionName
        }
        return assetCollections
    }
}

// MARK: - TTAAsset

extension TTAImagePickerManager {
    
    struct AssetManagerConst {
        static let assetSize = CGSize(width: 80, height: 80)
        static let assetMode = PHImageContentMode.aspectFill
        static let assetRequestOptions = _defaultOptions()
        
        private static func _defaultOptions() -> PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.version = .current
            return options
        }
    }
    
    static func fetchImage(for asset: PHAsset, size: CGSize, contentMode: PHImageContentMode? = AssetManagerConst.assetMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let options = options ?? AssetManagerConst.assetRequestOptions
        return PHCachingImageManager.default().requestImage(for: asset,
                                                     targetSize: size.toPixel(),
                                                    contentMode: contentMode ?? AssetManagerConst.assetMode,
                                                        options: options,
                                                  resultHandler: { (image, info) in
            if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                , image == nil && isInCloud.boolValue {
                options.isNetworkAccessAllowed = true
                _ = fetchImage(for: asset, size: size.toPixel(), contentMode: contentMode, options: options, resultHandler: resultHandler)
            } else {
                resultHandler(image, info)
            }
        })
    }
    
    static func cancelImageRequest(_ requestID: PHImageRequestID) {
        PHCachingImageManager.default().cancelImageRequest(requestID)
    }
    
    static func startCachingImages(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let manager = PHCachingImageManager.default() as? PHCachingImageManager
        let options = options ?? AssetManagerConst.assetRequestOptions
        manager?.startCachingImages(for: assets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
    }
    
    static func stopCachingImages(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let manager = PHCachingImageManager.default() as? PHCachingImageManager
        let options = options ?? AssetManagerConst.assetRequestOptions
        manager?.stopCachingImages(for: assets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
    }
    
    static func stopCachingImagesForAllAssets() {
        let manager = PHCachingImageManager.default() as? PHCachingImageManager
        manager?.stopCachingImagesForAllAssets()
    }
}

struct TTAIconFontManager {
    enum IconFont: String {
        case selectMark = "\u{e70d}"
    }
    
    struct IconFontSize {
        static let assetSelectMark: CGFloat = 15
    }
}
