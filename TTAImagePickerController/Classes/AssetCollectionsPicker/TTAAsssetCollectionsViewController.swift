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
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    let collections: [TTAAssetCollection]
    
    let assetPickerController: UINavigationController

    init(collections: [TTAAssetCollection], pickerController: UINavigationController) {
        self.collections = collections
        assetPickerController = pickerController
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Library"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
            print("TTAImagePickerController >>>>>> assec collection controller deinit")
        #endif
    }
}

// MARK: - Life Cycle

extension TTAAssetCollectionsViewController {
    
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
        tableView.register(TTAAssetCollectionsTableViewCell.self, forCellReuseIdentifier: "\(TTAAssetCollectionsTableViewCell.self)")
    }
    
    func _prepareCancelItem() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
}

// MARK: - Data

extension TTAAssetCollectionsViewController {
    
    func collectionCount() -> Int {
        return collections.count
    }
    
    func collection(at indexPath: IndexPath) -> TTAAssetCollection {
        return collections[indexPath.row]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TTAAssetCollectionsTableViewCell.self)", for: indexPath) as! TTAAssetCollectionsTableViewCell
        cell.collection = collection(at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TTAAssetCollectionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let splitViewController = splitViewController else { return }
        guard let pickerController = assetPickerController.topViewController as? TTAAssetPickerViewController else { return }
        pickerController.collection = collection(at: indexPath)
        splitViewController.showDetailViewController(assetPickerController, sender: nil)
    }
}
