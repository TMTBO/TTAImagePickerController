//
//  TTAImagePickerController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

public class TTAImagePickerController: UINavigationController, TTAImagePickerControllerCompatiable {
    
    public weak var pickerDelegate: TTAImagePickerControllerDelegate?
    
    public var allowTakePicture = true {
        didSet {
            configPicker { (_, assetVc) in
                assetVc?.allowTakePicture = allowTakePicture
            }
        }
    }
    
    /// The max num image of the image picker can pick, default is 9
    public var maxPickerNum = 9 {
        didSet {
            configPicker { (albumVc, assetVc) in
                albumVc?.maxPickerNum = maxPickerNum
                assetVc?.maxPickerNum = maxPickerNum
            }
        }
    }
    
    /// The selected asset
    public var selectedAsset: [TTAAsset] = [] {
        didSet {
            updateSelectedAsset()
        }
    }
    
    /// The tint color which item was selected, default is `UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor? = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            configPicker { (albumVc, assetVc) in
                albumVc?.selectItemTintColor = selectItemTintColor
                assetVc?.selectItemTintColor = selectItemTintColor
            }
        }
    }
    
    /// NavigationBar tintColor
    public var tintColor: UIColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            navigationBar.tintColor = tintColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: tintColor]
            guard let splitController = splitController else { return }
            _ = splitController.viewControllers.map { (viewController) in
                guard let viewController = viewController as? UINavigationController else { return }
                viewController.toolbar.tintColor = tintColor
                viewController.navigationBar.tintColor = tintColor
                viewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: tintColor]
            }
        }
    }
    
    /// NavigationBar barTintColor
    public var barTintColor: UIColor? {
        didSet {
            navigationBar.barTintColor = barTintColor
            guard let splitController = splitController else { return }
            _ = splitController.viewControllers.map { (viewController) in
                guard let viewController = viewController as? UINavigationController else { return }
                viewController.navigationBar.barTintColor = barTintColor
                viewController.toolbar.barTintColor = barTintColor
            }
        }
    }
    
    fileprivate(set) var splitController: UISplitViewController? = UISplitViewController()
    
    public convenience init(selectedAsset: [TTAAsset]?) {
        type(of: self).prepareIconFont()
        let rootVc = UIViewController()
        self.init(rootViewController: rootVc)
        prepareNavigationItems()
        
        self.selectedAsset = selectedAsset ?? []
        updateSelectedAsset()
        
        guard let splitController = splitController else { return }
        addChildViewController(splitController)
        rootVc.view.addSubview(splitController.view)
        splitController.view.backgroundColor = .clear
        splitController.preferredDisplayMode = .allVisible
        splitController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    deinit {
        splitController = nil
        #if DEBUG
            print("TTAImagePickerController >>>>>> deinit")
        #endif
    }

}

// MARK: - UI

extension TTAImagePickerController {
    func prepareNavigationItems() {
        guard let topViewController = topViewController else { return }
        topViewController.navigationItem.title = "\(TTAImagePickerController.self)"
        topViewController.navigationItem.hidesBackButton = true
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        topViewController.navigationItem.rightBarButtonItem = cancelItem
    }
    
    func updateSelectedAsset() {
        configPicker { (_, assetVc) in
            assetVc?.selected = selectedAsset.map { $0.original }
        }
    }
}

// MARK: - Life Cycle

extension TTAImagePickerController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkPermission()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let splitController = splitController else { return }
        splitController.view.frame = view.bounds
    }
}

// MARK: - Private

fileprivate extension TTAImagePickerController {
    func configPicker(_ handler: (_ albumVc: TTAAlbumPickerViewController?, _ assetVc: TTAAssetPickerViewController?) -> ()) {
        guard let splitController = splitController else { return }
        _ = splitController.viewControllers.map { (vc) in
            guard let nav = vc as? UINavigationController,
                let rootVc = nav.topViewController else { return }
            if let albumVc = rootVc as? TTAAlbumPickerViewController {
                handler(albumVc, nil)
            } else if let assetVc = rootVc as? TTAAssetPickerViewController {
                handler(nil, assetVc)
            }
        }
    }
}

// MARK: - Check Permission

extension TTAImagePickerController {
    func checkPermission() {
        func permissionDenied() {
            setNavigationBarHidden(false, animated: false)
            showPermissionView(with: .photo)
        }
        func startSetup() {
            setNavigationBarHidden(true, animated: false)
            prepareSplitController()
        }
        TTAImagePickerManager.checkPhotoLibraryPermission { (isAuthorized) in
            isAuthorized ? startSetup() : permissionDenied()
        }
    }
}

// MARK: - Actions

extension TTAImagePickerController {
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Generate Controllers

extension TTAImagePickerController {
    
    func prepareSplitController() {
        guard let splitController = splitController else { return }
        TTACachingImageManager.prepareCachingManager()
        let albums = TTAImagePickerManager.fetchAlbums()
        if let album = albums.first {
            let pickerController = _generateAssetController(with: album, selectedAsset: selectedAsset)
            let collectionController = _generateCollectionController(with: albums, pickerController: pickerController)
            splitController.viewControllers = [collectionController, pickerController]
        }
    }
    
    func _generateCollectionController(with collections: [TTAAlbum], pickerController: UINavigationController) -> UINavigationController {
        let assetCollectionController = TTAAlbumPickerViewController(albums: collections, pickerController: pickerController)
        assetCollectionController.maxPickerNum = maxPickerNum
        assetCollectionController.selectItemTintColor = selectItemTintColor
        TTACachingImageManager.addObserver(assetCollectionController)
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

// MARK: - Prepareation

extension TTAImagePickerController {
    static func prepareIconFont() {
        guard let url = Bundle.imagePickerBundle().url(forResource: "iconfont", withExtension: ".ttf") else { return }
        UIFont.registerFont(with: url, fontName: "iconfont")
    }
}

// MARK: - TTAAssetPickerViewControllerDelegate

extension TTAImagePickerController: TTAAssetPickerViewControllerDelegate {
    func assetPickerController(_ picker: TTAAssetPickerViewController, didFinishPicking assets: [PHAsset]) {
        fetchImages(with: assets) { [weak self] (images) in
            guard let `self` = self else { return }
            self.pickerDelegate?.imagePickerController(self, didFinishPicking: images, assets: assets.map({ TTAAsset(asset: $0) }))
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UISplitViewController {
    open override var prefersStatusBarHidden: Bool {
        guard let nav = viewControllers.last as? UINavigationController,
            let visibleVc = nav.visibleViewController else { return false }
        return visibleVc.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let nav = viewControllers.last as? UINavigationController,
            let visibleVc = nav.visibleViewController else { return .default }
        return visibleVc.preferredStatusBarStyle
    }
}
