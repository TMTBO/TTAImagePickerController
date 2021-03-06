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
    
    let original: PHAssetCollection
    let assets: PHFetchResult<PHAsset>
    let albumInfo: TTAAlbumInfo
    
    init(original: PHAssetCollection, assets: PHFetchResult<PHAsset>) {
        self.original = original
        self.assets = assets
        albumInfo = TTAAlbumInfo(album: original, assetCount: assets.count)
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
} /* TTAAlbum */

/// The Main user for this model is to avoid the user to `import Photos` in the file when they use `TTAImagePickerController`
public struct TTAAsset {
    let original: PHAsset
    public let assetInfo: TTAAssetInfo
    
    init(asset: PHAsset) {
        original = asset
        assetInfo = TTAAssetInfo(asset: asset)
    }
} /* TTAAsset */

struct TTAAssetConfig {
    let tag: Int
    let delegate: TTAAssetCollectionViewCellDelegate?
    let selectItemTintColor: UIColor?
    let isSelected: Bool
    let canSelect: Bool
    
    private(set) var isGif: Bool = false
    
    private(set) var isVideo: Bool = false
    private(set) var videoInfo = TTAAssetVideoInfo()

    init(asset: PHAsset, tag: Int, delegate: TTAAssetCollectionViewCellDelegate?, selectItemTintColor: UIColor?, isSelected: Bool, canSelect: Bool) {
        self.tag = tag
        self.delegate = delegate
        self.selectItemTintColor = selectItemTintColor
        self.isSelected = isSelected
        self.canSelect = canSelect
        
        if let fileName = asset.value(forKey: "filename") as? String {
            self.isGif = fileName.hasSuffix("GIF")
        }
        
        guard asset.isVideo else { return }
        self.isVideo = true
        videoInfo = TTAAssetVideoInfo(asset: asset)
    }
    
} /* TTAAssetConfig */

struct TTAAlbumInfo {
    let name: String
    let countString: String
    let isVideoAlbum: Bool
    let canShowCamera: Bool
    init(album: PHAssetCollection, assetCount: Int) {
        name = album.localizedTitle ?? ""
        countString = "\(assetCount)"
        isVideoAlbum = album.assetCollectionSubtype == .smartAlbumVideos || album.assetCollectionSubtype == .smartAlbumSlomoVideos
        canShowCamera = ["Camera Roll", "All Photos", "相机胶卷", "所有照片"].contains(name)
    }
} /* TTAAlbumInfo */

public struct TTAAssetInfo {
    public let isVideo: Bool
    public private(set) var videoInfo: TTAAssetVideoInfo? = nil
    init(asset: PHAsset) {
        isVideo = asset.isVideo
        if isVideo {
            videoInfo = TTAAssetVideoInfo(asset: asset)
        }
    }
}

public struct TTAAssetVideoInfo {
    public private(set) var timeLength: String = "00:00"
    
    init(asset: PHAsset) {
        if !hasConfigedDateComponentsFormatter {
            dateComponentsFormatter.zeroFormattingBehavior = .pad
            dateComponentsFormatter.allowedUnits = [.second, .minute]
            hasConfigedDateComponentsFormatter = true
        }
        timeLength = dateComponentsFormatter.string(from: asset.duration) ?? "00:00"
    }
    
    init() {
        // Do nothing here, for defatult
    }
} /* TTAFetchResult */

struct TTAFetchResult {
    enum TTAFetchResultInfoKey {
        case isGif
    }
    
    let image: UIImage?
    let playerItem: AVPlayerItem?
    let info: [AnyHashable: Any]?
}

extension TTAFetchResult {
    var hasImage: Bool {
        return image != nil
    }
    var hasPlayerItem: Bool {
        return playerItem != nil
    }
} /* TTAFetchResult */

extension PHAsset {
    var isVideo: Bool {
        return mediaType == .video
    }
    
    var isGif: Bool {
        guard let fileName = value(forKey: "filename") as? String,
            fileName.hasSuffix("GIF") == true else  { return false }
        return true
    }
} /* PHAsset */

struct TTAVideoProgressViewInfo {
    let currentString: String
    let durationString: String
    let progress: Float
    
    init(current: TimeInterval, duration: TimeInterval) {
        currentString = dateComponentsFormatter.string(from: current) ?? "00:00"
        durationString = dateComponentsFormatter.string(from: duration) ?? "00:00"
        progress = Float(current / duration)
    }
} /* TTAVideoProgressViewInfo */
