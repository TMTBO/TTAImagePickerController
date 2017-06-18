//
//  TTAAssetCollectionViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAssetCollectionViewController: UIViewController {
    
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

extension TTAAssetCollectionViewController {
    
    struct AssetCollectionViewControllerConst {
        static let assetCollectionTableViewCellIdentifier = "assetCollectionTableViewCellIdentifier"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
    
}

// MARK: - UI

extension TTAAssetCollectionViewController {
    
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
        tableView.register(TTAAssetCollectionTableViewCell.self, forCellReuseIdentifier: TTAAssetCollectionViewController.AssetCollectionViewControllerConst.assetCollectionTableViewCellIdentifier)
    }
    
    func _prepareCancelItem() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
}

// MARK: - Data

extension TTAAssetCollectionViewController {
    
    func collectionCount() -> Int {
        return TTAImagePickerManager.shared.assetCollections.count
    }
    
    func collection(at indexPath: IndexPath) -> TTAAssetCollection {
        return TTAImagePickerManager.shared.assetCollections[indexPath.row]
    }
}

// MARK: - Action

extension TTAAssetCollectionViewController {
    
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension TTAAssetCollectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TTAAssetCollectionViewController.AssetCollectionViewControllerConst.assetCollectionTableViewCellIdentifier, for: indexPath) as! TTAAssetCollectionTableViewCell
        cell.collection = collection(at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TTAAssetCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let assetPickerController = TTAAssetPickerViewController()
        self.navigationController?.pushViewController(assetPickerController, animated: true);
    }
}
