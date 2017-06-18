//
//  TTAImagePickerController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

public class TTAImagePickerController: UISplitViewController {
    
    /// The number of the image picker pre row, default is 4
    var columnNum = 4 {
        didSet {
            TTAImagePickerManager.shared.columnNum = columnNum
        }
    }
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9 {
        didSet {
            TTAImagePickerManager.shared.maxPickerNum = maxPickerNum
        }
    }
    
    /// NavigationBar tintColor
    public var tintColor: UIColor = UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            _ = viewControllers.map { (viewController) in
                let viewController = viewController as! UINavigationController
                viewController.navigationBar.tintColor = tintColor
                viewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: tintColor]
            }
        }
    }
    
    /// NavigationBar barTintColor
    public var barTintColor: UIColor? {
        didSet {
            _ = viewControllers.map { (viewController) in
                let viewController = viewController as! UINavigationController
                viewController.navigationBar.barTintColor = barTintColor
            }
        }
    }
    
    /// The tint color which item was selected, default is `.green`
    public var selectItemTintColor: UIColor? {
        didSet {
            TTAImagePickerManager.shared.selectItemTintColor = selectItemTintColor
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        if let colletction = TTAImagePickerManager.shared.assetCollections.first {
            let assetCollectionController = UINavigationController(rootViewController: TTAAssetCollectionsViewController())
            let assetPickerController = UINavigationController(rootViewController: TTAAssetPickerViewController(collection: colletction))
            viewControllers = [assetCollectionController, assetPickerController]
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Life Cycle

extension TTAImagePickerController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
