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
}

// MARK: - TTAAssetCollection

extension TTAImagePickerManager {
    
    static func fetchAssetCollections() -> [TTAAlbum] {
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        guard fetchResult.count > 0 else { return [TTAAlbum]() }
        
        var assetCollections: [TTAAlbum] = []
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchResult.enumerateObjects(options: .concurrent) { (assetCollection, _, _) in
            let assetResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            guard assetResult.count > 0 else { return }
            guard assetCollection.localizedTitle != "Videos" else { return }
            
            var assetCollectionModel = TTAAlbum()
            assetCollectionModel.originalAlbum = assetCollection
            assetCollectionModel.albumID = assetCollection.localIdentifier
            assetCollectionModel.albumName = assetCollection.localizedTitle
            assetCollectionModel.assetCount = assetResult.count
            
            var assets: [TTAAsset] = []
            assetResult.enumerateObjects({ (asset, _, _) in
                let ttaAsset = TTAAsset(originalAsset: asset)
                assets.append(ttaAsset)
            })
            
            assetCollectionModel.assets = assets
            assetCollectionModel.thumbnailAsset = assets.first
            
            assetCollections.append(assetCollectionModel)
        }
        assetCollections.sort { (collection1, collection2) -> Bool in
            return collection1.albumName < collection2.albumName
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
            return options
        }
    }
    
    static func fetchImage(for asset: TTAAsset, size: CGSize?, contentMode: PHImageContentMode? = AssetManagerConst.assetMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        let options = options ?? AssetManagerConst.assetRequestOptions
        let contentMode = contentMode ?? AssetManagerConst.assetMode
        let size = size ?? AssetManagerConst.assetSize
        
        TTACachingImageManager.shared?.manager.requestImage(for: asset.originalAsset, targetSize: size.toPixel(), contentMode: contentMode, options: options, resultHandler: { (image, info) in
            if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool
                , image == nil && isInCloud {
                options.isNetworkAccessAllowed = true
                _ = fetchImage(for: asset, size: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
            } else {
                if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                    return
                }
                DispatchQueue.global().async {
                    guard let fixedImage = fixOrientation(aImage: image) else {
                        DispatchQueue.main.async {
                            resultHandler(image, info)
                        }
                        return
                    }
                    guard let scaledImage = scaleImage(image: fixedImage, to: size.toPixel()) else {
                        DispatchQueue.main.async {
                            resultHandler(fixedImage, info)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        resultHandler(scaledImage, info)
                    }
                }
            }
        })
    }
}

// MARK: - Image Fix

extension TTAImagePickerManager {
    
    static func scaleImage(image: UIImage, to size: CGSize) -> UIImage? {
        if image.size.width > size.width {
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return image
        }
    }
    
    static func fixOrientation(aImage: UIImage?) -> UIImage? {
        guard let aImage = aImage else { return nil}
        if aImage.imageOrientation == .up { return aImage }
        
        var transform = CGAffineTransform.identity
        
        switch aImage.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: aImage.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }
        
        switch aImage.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: -1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: -1)
        default:
            break
        }
        
        guard let cgImage = aImage.cgImage,
            let colorSpace = cgImage.colorSpace,
            let ctx = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return aImage }
        
        ctx.concatenate(transform)
        switch aImage.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
        }
        
        guard let cgImg = ctx.makeImage() else { return aImage}
        let resultImage = UIImage(cgImage: cgImg)
        return resultImage
    }
}

// MARK: - Caching

struct TTACachingImageManager {
    
    static var shared:TTACachingImageManager? = TTACachingImageManager()
    let manager = PHCachingImageManager()
    
    func startCachingImages(for assets: [TTAAsset], targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            let originalAssets = assets.map { return $0.originalAsset }
            let options = options ?? TTAImagePickerManager.AssetManagerConst.assetRequestOptions
            let contentMode = contentMode ?? TTAImagePickerManager.AssetManagerConst.assetMode
            let targetSize = targetSize ?? TTAImagePickerManager.AssetManagerConst.assetSize
            self.manager.startCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    func stopCachingImages(for assets: [TTAAsset], targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            let originalAssets = assets.map { return $0.originalAsset }
            let options = options ?? TTAImagePickerManager.AssetManagerConst.assetRequestOptions
            let contentMode = contentMode ?? TTAImagePickerManager.AssetManagerConst.assetMode
            let targetSize = targetSize ?? TTAImagePickerManager.AssetManagerConst.assetSize
            self.manager.stopCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    func stopCachingImagesForAllAssets() {
        manager.stopCachingImagesForAllAssets()
    }
    
    static func prepareCachingManager() {
        if shared != nil { return }
        shared = TTACachingImageManager()
    }
    
    static func destoryCachingManager() {
        shared?.manager.stopCachingImagesForAllAssets()
        shared = nil
    }
}
