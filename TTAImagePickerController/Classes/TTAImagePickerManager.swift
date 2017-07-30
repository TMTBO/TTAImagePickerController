//
//  TTAImagePickerManager.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import Photos

let dateFormatter = DateFormatter()
let dateComponentsFormatter = DateComponentsFormatter()

var hasConfigedDateFormatter = false
var hasConfigedDateComponentsFormatter = false

class TTAImagePickerManager {
    static func defaultOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        return options
    }
    
    static func fetchOriginalOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        return options
    }
    
    static func defaultMode() -> PHImageContentMode {
        return PHImageContentMode.aspectFill
    }
    
    static func defaultSize() -> CGSize {
        return CGSize(width: 104, height: 104)
    }
    
    static func fetchOriginalSize(with asset: PHAsset?) -> CGSize {
        guard let asset = asset else { return defaultSize() }
        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }
}

// MARK: - PhotoLibraryPermission

extension TTAImagePickerManager {
    static func checkPhotoLibraryPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
        func hasPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        func needToRequestPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        }
        func requestPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    self.checkPhotoLibraryPermission(resultHandler)
                }
            }
        }
        hasPermission() ? resultHandler(true) : (needToRequestPermission() ? requestPermission(resultHandler) : resultHandler(false))
    }
}

// MARK: - TTAAssetCollection

extension TTAImagePickerManager {
    
    static func fetchAssetCollections() -> [TTAAlbum] {
        let hud = TTAHUD.showIndicator(with: .indicator)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        guard fetchResult.count > 0 else { return [TTAAlbum]() }
        
        var assetCollections: [TTAAlbum] = []
        
        let options = PHFetchOptions()
        let imagePredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let videoPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        options.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [imagePredicate, videoPredicate])
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchResult.enumerateObjects(options: .concurrent) { (assetCollection, _, _) in
            let assetResult = PHAsset.fetchAssets(in: assetCollection, options: options)
            guard assetResult.count > 0 else { return }
            
            let album = TTAAlbum(original: assetCollection, assets: assetResult)
            assetCollections.append(album)
        }
        assetCollections.sort { (collection1, collection2) -> Bool in
            return collection1.albumInfo.name < collection2.albumInfo.name
        }
        hud.dimiss()
        return assetCollections
    }
}

// MARK: - Fetch Image | Video | Gif

extension TTAImagePickerManager {
    static func fetchImages(for assets: [PHAsset], size: CGSize? = PHImageManagerMaximumSize, options: PHImageRequestOptions? = nil, progressHandler: PHAssetImageProgressHandler?,resultHandler: @escaping ([UIImage]) -> Void) {
        // Because of the `isSynchronous` is `true`, if call `fetchOriginalImage` to  download the image from icloud in mainThread, then the mainThread will be blocked and the progressHandler will not excuated
        DispatchQueue.global().async {
            var images: [UIImage] = []
            let options = fetchOriginalOptions()
            options.isSynchronous = true
            let group = DispatchGroup()
            _ = assets.map { (asset) in
                group.enter()
                fetchOriginalImage(for: asset, options: options, progressHandler: progressHandler, resultHandler: { (image) in
                    if let image = image {
                        images.append(image)
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                resultHandler(images)
            }
        }
    }
    
    static func fetchPreview(for asset: PHAsset?, progressHandler: PHAssetImageProgressHandler?, resultHandler: @escaping (TTAFetchResult) -> Void) {
        fetchImage(for: asset, size: fetchOriginalSize(with: asset), options: defaultOptions(), progressHandler:progressHandler) { (image, info) in
            let result = TTAFetchResult(image: image, playerItem: nil, info: info)
            resultHandler(result)
            if let fileName = asset?.value(forKey: "filename") as? String,
                fileName.hasSuffix("GIF") == true {
                fetchImageData(for: asset, size: fetchOriginalSize(with: asset), options: defaultOptions(), progressHandler: nil) { (image, isGif, info) in
                    let fetchInfo: [AnyHashable: Any]
                    if var resultInfo = info {
                        resultInfo[TTAFetchResult.TTAFetchResultInfoKey.isGif] = isGif
                        fetchInfo = resultInfo
                    } else {
                        fetchInfo = [:]
                    }
                    let result = TTAFetchResult(image: image, playerItem: nil, info: fetchInfo)
                    resultHandler(result)
                }
            } else if let isVideo = asset?.isVideo,
                isVideo == true {
                fetchVideoItem(for: asset, resultHandler: { (fetchResult) in
                    resultHandler(fetchResult)
                })
            }
        }
    }
    
    static func fetchOriginalImage(for asset: PHAsset?, options: PHImageRequestOptions, progressHandler: PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?) -> Void) {
        fetchImage(for: asset, size: fetchOriginalSize(with: asset), options: options, progressHandler: progressHandler) { (image, info) in
            resultHandler(image)
        }
    }
    
    static func fetchVideoItem(for asset: PHAsset?, resultHandler: @escaping (TTAFetchResult) -> Void) {
        fetchPlayerItem(for: asset, progressHandler: nil) { (playerItem, info) in
            let result = TTAFetchResult(image: nil, playerItem: playerItem, info: info)
            resultHandler(result)
        }
    }
    
}

// MARK: - Fetch Asset
extension TTAImagePickerManager {
    
    static func fetchImage(for asset: PHAsset?, size: CGSize, options: PHImageRequestOptions, progressHandler: PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        guard let asset = asset else { resultHandler(nil, nil); return }
        
        TTACachingImageManager.shared?.manager.requestImage(for: asset, targetSize: size, contentMode: defaultMode(), options: options, resultHandler: { (image, info) in
            if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool
                , image == nil && isInCloud {
                options.isNetworkAccessAllowed = true
                options.progressHandler = { (progress, error, stop, info) in
                    DispatchQueue.main.async {
                        progressHandler?(progress, error, stop, info)
                    }
                }
                TTACachingImageManager.shared?.manager.requestImage(for: asset, targetSize: size.toPixel(), contentMode: defaultMode(), options: options, resultHandler: resultHandler)
            } else {
                if let cancelled = info?[PHImageCancelledKey] as? Bool, info?[PHImageErrorKey] != nil && cancelled {
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
    
    static func fetchImageData(for asset: PHAsset?, size: CGSize, options: PHImageRequestOptions, progressHandler: PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?, Bool, [AnyHashable: Any]?) -> Void) {
        guard let asset = asset else { resultHandler(nil, false, nil); return }
        
        func handlerResult(with data: Data?, info: [AnyHashable: Any]?, resultHandler: (UIImage?, Bool, [AnyHashable: Any]?) -> Void) {
            guard let imageData = data else { resultHandler(nil, false, nil); return }
            let isGif = imageData.imageContentType == .gif
            let image: UIImage?
            if isGif {
                image = imageData.animatedGIF
            } else {
                image = UIImage(data: imageData, scale: UIScreen.main.scale)
            }
            resultHandler(image, isGif, info)
            /*
            DispatchQueue.global().async {
                guard let fixedImage = fixOrientation(aImage: image) else {
                    DispatchQueue.main.async {
                        resultHandler(image, isGif)
                    }
                    return
                }
                guard let scaledImage = scaleImage(image: fixedImage, to: size.toPixel()) else {
                    DispatchQueue.main.async {
                        resultHandler(fixedImage, isGif)
                    }
                    return
                }
                DispatchQueue.main.async {
                    resultHandler(scaledImage, isGif)
                }
            }
            */
        }
        
        TTACachingImageManager.shared?.manager.requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, orientation, info) in
            if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool
                , data == nil && isInCloud {
                options.isNetworkAccessAllowed = true
                options.progressHandler = { (progress, error, stop, info) in
                    DispatchQueue.main.async {
                        progressHandler?(progress, error, stop, info)
                    }
                }
                TTACachingImageManager.shared?.manager.requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, orientation, info) in
                    handlerResult(with: data, info: info, resultHandler: resultHandler)
                })
            } else {
                if let cancelled = info?[PHImageCancelledKey] as? Bool, info?[PHImageErrorKey] != nil && cancelled {
                    return
                }
                handlerResult(with: data, info: info, resultHandler: resultHandler)
            }
        })
    }
    
    static func fetchPlayerItem(for asset: PHAsset?, progressHandler: PHAssetVideoProgressHandler?, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) {
        guard let asset = asset else { resultHandler(nil, nil); return }
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.sync {
                progressHandler?(progress, error, stop, info)
            }
        }
        TTACachingImageManager.shared?.manager.requestPlayerItem(forVideo: asset, options: options, resultHandler: { (playerItem, info) in
            resultHandler(playerItem, info)
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
    
    static var shared: TTACachingImageManager? = TTACachingImageManager()
    let manager = PHCachingImageManager()
    
    func startCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager.defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager.defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager.defaultSize()
            self.manager.startCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    func stopCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager.defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager.defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager.defaultSize()
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
