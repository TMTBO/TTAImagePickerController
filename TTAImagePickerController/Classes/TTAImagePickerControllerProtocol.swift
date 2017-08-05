//
//  TTAImagePickerControllerProtocol.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 05/08/2017.
//

import Photos

public protocol TTAImagePickerControllerDelegate: class {
    func imagePickerController(_ picker: TTAImagePickerControllerCompatiable, didFinishPicking images: [UIImage], assets: [TTAAsset])
} /* TTAImagePickerControllerDelegate */

// MARK: - Option Functions
public protocol TTAImagePickerControllerCompatiable {
    func fetchImages(with assets: [PHAsset], completionHandler: @escaping ([UIImage]) -> ())
}

public extension TTAImagePickerControllerCompatiable {
    func fetchImages(with assets: [PHAsset], completionHandler: @escaping ([UIImage]) -> ()) {
        let hud = TTAHUD.showIndicator(with: .indicator)
        TTAImagePickerManager.fetchImages(for: assets, progressHandler: { (progress, error, stop, info) -> Void in
            hud.updateTip(Bundle.localizedString(for: "Loading from icloud..."))
            hud.updateProgress(progress)
        }) { (images) in
            completionHandler(images)
            hud.dimiss()
        }
    }
} /* TTAImagePickerControllerCompatiable */

protocol TTAOperateAssetProtocol: class {
    var selected: [PHAsset] { get set }
    var maxPickerNum: Int { get }
    func canOperateAsset(_ asset: PHAsset) -> Bool
    func operateAsset(_ asset: PHAsset, isSelected: Bool)
    func updateCounter()
}

extension TTAOperateAssetProtocol {
    func canOperateAsset(_ asset: PHAsset) -> Bool {
        guard !selected.contains(asset) else { return true }
        if selected.count >= maxPickerNum {
            return false
        }
        return true
    }
    
    func operateAsset(_ asset: PHAsset, isSelected: Bool) {
        if isSelected {
            selected.append(asset)
        } else {
            guard let index = selected.index(of: asset) else { return }
            selected.remove(at: index)
        }
        updateCounter()
    }
} /* TTAOperateAssetProtocol */
