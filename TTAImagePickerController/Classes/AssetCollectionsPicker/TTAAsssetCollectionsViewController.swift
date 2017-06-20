//
//  TTAAssetCollectionsViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAssetCollectionsViewController: UIViewController {
    
    fileprivate let tableView = UITableView()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Library"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle

extension TTAAssetCollectionsViewController {
    
    struct AssetCollectionsViewControllerConst {
        static let assetCollectionsTableViewCellIdentifier = "assetCollectionTableViewCellIdentifier"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
    
}

// MARK: - UI

extension TTAAssetCollectionsViewController {
    
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
    }
    
    func _createViews() {
        view.addSubview(tableView)
        _prepareCancelItem()
    }
    
    func _configViews() {
        view.backgroundColor = .white
        _prepareTableView()
    }
    
    func _layoutViews() {
        tableView.frame = view.bounds
    }
    
    func _prepareTableView() {
        tableView.rowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(TTAAssetCollectionsTableViewCell.self, forCellReuseIdentifier: TTAAssetCollectionsViewController.AssetCollectionsViewControllerConst.assetCollectionsTableViewCellIdentifier)
    }
    
    func _prepareCancelItem() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
}

// MARK: - Data

extension TTAAssetCollectionsViewController {
    
    func collectionCount() -> Int {
        return TTAImagePickerManager.shared.assetCollections.count
    }
    
    func collection(at indexPath: IndexPath) -> TTAAssetCollection {
        return TTAImagePickerManager.shared.assetCollections[indexPath.row]
    }
}

// MARK: - Action

extension TTAAssetCollectionsViewController {
    
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource

extension TTAAssetCollectionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TTAAssetCollectionsViewController.AssetCollectionsViewControllerConst.assetCollectionsTableViewCellIdentifier, for: indexPath) as! TTAAssetCollectionsTableViewCell
        cell.collection = collection(at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TTAAssetCollectionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let splitViewController = splitViewController else { return }
        let assetPickerController: UIViewController
        // on the iPhone (compact) the split view controller is collapsed
        // therefore we need to create the navigation controller and its image view controllerfirst
        if (splitViewController.isCollapsed) {
            assetPickerController = TTAAssetPickerViewController(collection: collection(at: indexPath))
        } else { // if the split view controller shows the detail view already there is no need to create the controllers, for ipad
            guard let assetNavPickerController = splitViewController.viewControllers.last as? UINavigationController,
                let pickerController = assetNavPickerController.topViewController as? TTAAssetPickerViewController else { return }
            pickerController.collection = collection(at: indexPath)
            assetPickerController = assetNavPickerController
        }
        splitViewController.showDetailViewController(assetPickerController, sender: nil)
    }
}
