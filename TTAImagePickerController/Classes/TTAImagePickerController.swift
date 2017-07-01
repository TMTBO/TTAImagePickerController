//
//  TTAImagePickerController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

public protocol TTAImagePickerControllerDelegate { }

public extension TTAImagePickerControllerDelegate {
    public func imagePickerController(_ picker: TTAImagePickerController, didFinishPicking images: [UIImage], assets: [TTAAsset]) {
        
    }
}

public class TTAImagePickerController: UIViewController {
    
    public var delegate: TTAImagePickerControllerDelegate?
    
    /// The max num image of the image picker can pick, default is 9
    public var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    /// NavigationBar tintColor
    public var tintColor: UIColor = UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            _ = splitController.viewControllers.map { (viewController) in
                let viewController = viewController as! UINavigationController
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        splitController.view.frame = view.bounds
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
        let nav = UINavigationController(rootViewController: assetPickerController)
        return nav
    }
}
