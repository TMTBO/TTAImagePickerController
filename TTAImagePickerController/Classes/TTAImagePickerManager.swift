//
//  TTAImagePickerManager.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import Photos
import AssetsLibrary

let dateFormatter = DateFormatter()
let dateComponentsFormatter = DateComponentsFormatter()

var hasConfigedDateFormatter = false
var hasConfigedDateComponentsFormatter = false

final class TTAImagePickerManager {
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

// MARK: - Permission

extension TTAImagePickerManager {
    
    static func checkPhotoLibraryPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
        func hasPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        
        func needToRequestPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        }
        
        func requestPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
            PHPhotoLibrary.requestAuthorization { (_) in
                DispatchQueue.main.async {
                    self.checkPhotoLibraryPermission(resultHandler)
                }
            }
        }
        
        hasPermission() ? resultHandler(true) : (needToRequestPermission() ? requestPermission(resultHandler) : resultHandler(false))
    }
    
    static func checkCameraPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
        func hasCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        }
        
        func needToRequestCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined
        }
        
        func requestPermission(_ resultHandler: @escaping (_ isAuthorized: Bool) -> Swift.Void) {
            #if arch(i386) || arch(x86_64)
                TTAHUD.showTip(Bundle.localizedString(for: "PHONE SIMULATOR NOT Support Camera"))
            #else
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (_) in
                    DispatchQueue.main.async {
                        self.checkCameraPermission(resultHandler)
                    }
                }
            #endif
        }
        
        hasCameraPermission() ? resultHandler(true) : (needToRequestCameraPermission() ? requestPermission(resultHandler) : resultHandler(false))
    }
}

// MARK: - TTAAssetCollection

extension TTAImagePickerManager {
    static func fetchAlbums(isLoading: Bool = true) -> [TTAAlbum] {
        let hud: TTAHUD? = isLoading ? TTAHUD.showIndicator(with: .indicator) : nil
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
        hud?.dimiss()
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
            if let asset = asset, asset.isGif {
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
        if let asset = asset, asset.isGif {
            fetchImageData(for: asset, size: fetchOriginalSize(with: asset), options: defaultOptions(), progressHandler: nil) { (image, isGif, info) in
                resultHandler(image)
            }
        } else {
            fetchImage(for: asset, size: fetchOriginalSize(with: asset), options: options, progressHandler: progressHandler) { (image, info) in
                resultHandler(image)
            }
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
            DispatchQueue.main.async {
                resultHandler(playerItem, info)
            }
        })
    }
    
    static func fetchVideo(for asset: PHAsset?, progressHandler: PHAssetVideoProgressHandler?, resultHandler: @escaping (String?) -> Void) {
        guard let asset = asset else { resultHandler(nil); return }
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        options.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.sync {
                progressHandler?(progress, error, stop, info)
            }
        }
        TTACachingImageManager.shared?.manager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, audioMix, info) in
            guard let asset = asset as? AVURLAsset else { return }
            exportVideo(with: asset, resultHandler: resultHandler)
        })
    }
}

// MARK: - Export Video

extension TTAImagePickerManager {
    static func exportVideo(with asset: AVURLAsset, resultHandler: ((String?) -> Void)?) {
        let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        guard presets.contains(AVAssetExportPreset640x480),
            let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else { return }
        
        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let outputPath = NSHomeDirectory().appending("/tmp/output-\(formatter.string(from: Date())).mp4")
        session.outputURL = URL(fileURLWithPath: outputPath)
        session.shouldOptimizeForNetworkUse = true
        
        let supportTypes = session.supportedFileTypes
        if supportTypes.contains(AVFileType.mp4) {
            session.outputFileType = AVFileType.mp4
        } else if supportTypes.count == 0 {
            #if DEBUG
                print(Bundle.localizedString(for: "NO supported file types"))
            #endif
        } else {
            session.outputFileType = supportTypes.first
        }
        
        let tmpPath = NSHomeDirectory().appending("/tmp")
        if !FileManager.default.fileExists(atPath: tmpPath) {
            try? FileManager.default.createDirectory(atPath: tmpPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let videoCompostion = fixedComposition(with: asset)
        
        if videoCompostion.renderSize.width != 0 {
            session.videoComposition = videoCompostion
        }
        
        session.exportAsynchronously {
            switch session.status {
            case .unknown:
                #if DEBUG
                    print(Bundle.localizedString(for: "Export Video status unknown"))
                #endif
            case .waiting:
                #if DEBUG
                    print(Bundle.localizedString(for: "Export Video status waiting"))
                #endif
            case .exporting:
                #if DEBUG
                    print(Bundle.localizedString(for: "Export Video status exporting"))
                #endif
            case .failed:
                #if DEBUG
                    print(Bundle.localizedString(for: "Export Video status failed : \(String(describing: session.error))"))
                #endif
            case .completed:
                #if DEBUG
                    print(Bundle.localizedString(for: "Export Video status completed"))
                #endif
                DispatchQueue.main.async {
                    resultHandler?(outputPath)
                }
            default:
                break
            }
        }
    }
}

// MARK: - Save Image

extension TTAImagePickerManager {
    static func save(image: UIImage, completionHandler: @escaping (Bool) -> ()) {
        if #available(iOS 9.0, *) {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.creationRequestForAsset(from: image)
                request.creationDate = Date()
            }) { (isSuccess, error) in
                DispatchQueue.main.async {
                    completionHandler(isSuccess)
                }
                #if DEBUG
                    if let err = error {
                        print("Save Image error! \n \(err.localizedDescription)")
                    }
                #endif
            }
        } else {
            ALAssetsLibrary().writeImage(toSavedPhotosAlbum: image.cgImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: { (assetUrl, error) in
                if let err = error {
                    #if DEBUG
                        print("Save Image error! \n \(err.localizedDescription)")
                    #endif
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        completionHandler(assetUrl != nil)
                    })
                }
            })
        }
    }
}

// MARK: - Delete Image

extension TTAImagePickerManager {
    static func delete(asset: PHAsset, completionHandler: @escaping (Bool) -> ()) {
        delete(assets: [asset], completionHandler: completionHandler)
    }
    
    static func delete(assets: [PHAsset], completionHandler: @escaping (Bool) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                completionHandler(isSuccess)
            }
            #if DEBUG
                if let err = error {
                    print("Save Image error! \n \(err.localizedDescription)")
                }
            #endif
        }
    }
}

// MARK: - Fix Image

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

// MARK: - Video Asset Fix

extension TTAImagePickerManager {
    static func fixedComposition(with asset: AVAsset) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        let degrees = degressFromVideoFile(with: asset)
        guard degrees != 0 else { return videoComposition }
        let translateToCenter: CGAffineTransform
        let mixedTransform: CGAffineTransform
        videoComposition.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
        
        let tracks = asset.tracks(withMediaType: AVMediaType.video)
        guard let videoTrack = tracks.first else { return videoComposition }
        
        let roateInstruction = AVMutableVideoCompositionInstruction()
        roateInstruction.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let roateLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        if degrees == 90 {
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi / 2)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: CMTime.zero)
        } else if degrees == 180 {
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: videoTrack.naturalSize.height)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
            roateLayerInstruction.setTransform(mixedTransform, at: CMTime.zero)
        } else if degrees == 270 {
            translateToCenter = CGAffineTransform(translationX: 0, y: videoTrack.naturalSize.width)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi * 3 / 2)
            videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: CMTime.zero)
        }
        roateInstruction.layerInstructions = [roateLayerInstruction]
        videoComposition.instructions = [roateInstruction]
        return videoComposition
    }
    
    static func degressFromVideoFile(with asset: AVAsset) -> Int {
        var degress = 0
        let tracks = asset.tracks(withMediaType: AVMediaType.video)
        guard tracks.count > 0,
            let videoTrack = tracks.first else { return degress}
        let t = videoTrack.preferredTransform
        if t.a == 0 && t.b == 1 && t.c == -1 && t.d == 0 {
            degress = 90
        } else if t.a == 0 && t.b == -1 && t.c == 1 && t.d == 0 {
            degress = 270
        } else if t.a == 1 && t.b == 0 && t.c == 0 && t.d == 1 {
            degress = 0
        } else if t.a == -1 && t.b == 0 && t.c == 0 && t.d == -1 {
            degress = 180
        }
        return degress
    }
}

// MARK: - TTACachingImageManager

final class TTACachingImageManager: NSObject {
    
    static fileprivate var shared: TTACachingImageManager?
    let manager = PHCachingImageManager()
    fileprivate let observers = NSHashTable<AnyObject>.weakObjects()
    
    static func prepareCachingManager() {
        guard shared == nil else  { return }
        shared = TTACachingImageManager()
        PHPhotoLibrary.shared().register(shared!)
    }
    
    static func destoryCachingManager() {
        guard let sharedInstance = shared else { return }
        sharedInstance.manager.stopCachingImagesForAllAssets()
        sharedInstance.observers.removeAllObjects()
        PHPhotoLibrary.shared().unregisterChangeObserver(sharedInstance)
        shared = nil
    }
}

// MARK: - Observers

extension TTACachingImageManager {
    static func addObserver(_ object: AnyObject) {
        shared?.observers.add(object)
    }
    
    static func removeObserver(_ object: AnyObject) {
        shared?.observers.remove(object)
    }
    
    func notifyObersvers() {
        for object in observers.allObjects {
            DispatchQueue.main.async {
                let _ = object.perform(
                    #selector(TTACachingImageManagerObserver.cachingImageManager(_:photoLibraryDidChangeObserver:)),
                    with: self,
                    with: object)
            }
        }
    }
}

// MARK: - Caching

extension TTACachingImageManager {
    
    static func startCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        guard let sharedInstance = shared else { return }
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager.defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager.defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager.defaultSize()
            sharedInstance.manager.startCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    static func stopCachingImages(for assets: PHFetchResult<PHAsset>, targetSize: CGSize?, contentMode: PHImageContentMode?, options: PHImageRequestOptions?) {
        guard let sharedInstance = shared else { return }
        DispatchQueue.global().async {
            var originalAssets: [PHAsset] = []
            assets.enumerateObjects({ (asset, index, isStop) in
                originalAssets.append(asset)
            })
            let options = options ?? TTAImagePickerManager.defaultOptions()
            let contentMode = contentMode ?? TTAImagePickerManager.defaultMode()
            let targetSize = targetSize ?? TTAImagePickerManager.defaultSize()
            sharedInstance.manager.stopCachingImages(for: originalAssets, targetSize: targetSize.toPixel(), contentMode: contentMode, options: options)
        }
    }
    
    static func stopCachingImagesForAllAssets() {
        guard let sharedInstance = shared else { return }
        sharedInstance.manager.stopCachingImagesForAllAssets()
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension TTACachingImageManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        type(of: self).stopCachingImagesForAllAssets()
        notifyObersvers()
    }
}

@objc protocol TTACachingImageManagerObserver: NSObjectProtocol {
    @objc func cachingImageManager(_ manager: TTACachingImageManager, photoLibraryDidChangeObserver: AnyObject)
}
