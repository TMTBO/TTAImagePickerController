//
//  TTAImagePickerController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

public protocol TTAImagePickerControllerDelegate: class {
    func imagePickerController(_ picker: TTAImagePickerController, didFinishPicking images: [UIImage], assets: [TTAAsset])
}

// MARK: - Option Functions
extension TTAImagePickerControllerDelegate {
    
}

public class TTAImagePickerController: UIViewController {
    
    public weak var delegate: TTAImagePickerControllerDelegate?
    
    /// The max num image of the image picker can pick, default is 9
    public var maxPickerNum = 9 {
        didSet {
            _ = splitController.viewControllers.map { (vc) in
                guard let nav = vc as? UINavigationController,
                    let rootVc = nav.topViewController else { return }
                if let albumVc = rootVc as? TTAAlbumPickerViewController {
                    albumVc.selectItemTintColor = selectItemTintColor
                } else if let assetVc = rootVc as? TTAAssetPickerViewController {
                    assetVc.selectItemTintColor = selectItemTintColor
                }
            }
        }
    }
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor? = UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            _ = splitController.viewControllers.map { (vc) in
                guard let nav = vc as? UINavigationController,
                    let rootVc = nav.topViewController else { return }
                if let albumVc = rootVc as? TTAAlbumPickerViewController {
                    albumVc.selectItemTintColor = selectItemTintColor
                } else if let assetVc = rootVc as? TTAAssetPickerViewController {
                    assetVc.selectItemTintColor = selectItemTintColor
                }
            }
        }
    }
    
    /// NavigationBar tintColor
    public var tintColor: UIColor = UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            _ = splitController.viewControllers.map { (viewController) in
                guard let viewController = viewController as? UINavigationController else { return }
                viewController.navigationBar.tintColor = tintColor
                viewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: tintColor]
            }
        }
    }
    
    /// NavigationBar barTintColor
    public var barTintColor: UIColor? {
        didSet {
            _ = splitController.viewControllers.map { (viewController) in
                let viewController = viewController as! UINavigationController
                viewController.navigationBar.barTintColor = barTintColor
            }
        }
    }
    
    fileprivate let splitController = UISplitViewController()
    
    public init(selectedAsset: [TTAAsset]) {
        super.init(nibName: nil, bundle: nil)
        let albums = TTAImagePickerManager.fetchAssetCollections()
        if let album = albums.first {
            let pickerController = _generateAssetController(with: album, selectedAsset: selectedAsset)
            let collectionController = _generateCollectionController(with: albums, pickerController: pickerController)
            splitController.viewControllers = [collectionController, pickerController]
        }
        addChildViewController(splitController)
        view.addSubview(splitController.view)
        splitController.preferredDisplayMode = .allVisible
        splitController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
            print("TTAImagePickerController >>>>>> deinit")
        #endif
    }

}

// MARK: - Life Cycle

extension TTAImagePickerController {
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        splitController.view.frame = view.bounds
    }
    
    public override var prefersStatusBarHidden: Bool {
        guard let nav = splitController.viewControllers.last as? UINavigationController,
            let visibleVc = nav.visibleViewController else { return false }
        return visibleVc.prefersStatusBarHidden
    }
}

// MARK: - Generate Controllers

extension TTAImagePickerController {
    
    func _generateCollectionController(with collections: [TTAAlbum], pickerController: UINavigationController) -> UINavigationController {
        let assetCollectionController = TTAAlbumPickerViewController(albums: collections, pickerController: pickerController)
        assetCollectionController.maxPickerNum = maxPickerNum
        assetCollectionController.selectItemTintColor = selectItemTintColor
        let nav = UINavigationController(rootViewController: assetCollectionController)
        return nav
    }
    
    func _generateAssetController(with album: TTAAlbum, selectedAsset: [TTAAsset]) -> UINavigationController {
        let assetPickerController = TTAAssetPickerViewController(album: album, selectedAsset: selectedAsset.map({ $0.original }))
        assetPickerController.maxPickerNum = maxPickerNum
        assetPickerController.selectItemTintColor = selectItemTintColor
        assetPickerController.delegate = self
        let nav = UINavigationController(rootViewController: assetPickerController)
        return nav
    }
}

// MARK: - TTAAssetPickerViewControllerDelegate

extension TTAImagePickerController: TTAAssetPickerViewControllerDelegate {
    func assetPickerController(_ picker: TTAAssetPickerViewController, didFinishPicking assets: [PHAsset]) {
        TTAImagePickerManager.fetchImages(for: assets) { [weak self] (images) in
            guard let `self` = self else { return }
            self.delegate?.imagePickerController(self, didFinishPicking: images, assets: assets.map({ TTAAsset(original: $0) }))
        }
    }
}
