//
//  TTAImagePickerManager.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import Photos

class TTAImagePickerManager {
    static func _defaultOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        return options
    }
    
    static func _defaultMode() -> PHImageContentMode {
        return PHImageContentMode.aspectFill
    }
    
    static func _defaultSize() -> CGSize {
        return CGSize(width: 104, height: 104)
    }
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
            let assetResult = PHAsset.fetchAssets(in: assetCollection, options: options)
            guard assetResult.count > 0 else { return }
            guard assetCollection.localizedTitle != "Videos" else { return }
            
            var album = TTAAlbum()
            album.original = assetCollection
            album.assets = assetResult
            assetCollections.append(album)
        }
        assetCollections.sort { (collection1, collection2) -> Bool in
            return collection1.name() ?? "" < collection2.name() ?? ""
        }
        return assetCollections
    }
}

// MARK: - TTAAsset

extension TTAImagePickerManager {
    
    static func fetchImage(for asset: PHAsset?, size: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        
        guard let asset = asset else { resultHandler(nil, nil); return }
        
        let options = options ?? _defaultOptions()
        let contentMode = contentMode ?? _defaultMode()
        let size = size ?? _defaultSize()
        
        TTACachingImageManager.shared?.manager.requestImage(for: asset, targetSize: size.toPixel(), contentMode: contentMode, options: options, resultHandler: { (image, info) in
            if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool
                , image == nil && isInCloud {
                options.isNetworkAccessAllowed = true
                _ = fetchImage(for: asset, size: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
            } else {
                if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                    return
                }
                resultHandler(image, info)
                
/*
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
 */
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
    
    func startCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager._defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager._defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager._defaultSize()
            self.manager.startCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    func stopCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager._defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager._defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager._defaultSize()
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
