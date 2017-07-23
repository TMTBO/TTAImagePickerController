//
//  TTAAlbumPickerViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAlbumPickerViewController: UIViewController {
    
    fileprivate let tableView = UITableView()
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    let albums: [TTAAlbum]
    
    let assetPickerController: UINavigationController

    init(albums: [TTAAlbum], pickerController: UINavigationController) {
        self.albums = albums
        assetPickerController = pickerController
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = Bundle.localizedString(for: "Library")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
            print("TTAImagePickerController >>>>>> Album Picker Controller deinit")
        #endif
    }
}

// MARK: - Life Cycle

extension TTAAlbumPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
    
}

// MARK: - UI

extension TTAAlbumPickerViewController {
    
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
        tableView.register(TTAAlbumTableViewCell.self, forCellReuseIdentifier: "\(TTAAlbumTableViewCell.self)")
    }
    
    func _prepareCancelItem() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
}

// MARK: - Data

extension TTAAlbumPickerViewController {
    
    func albumCount() -> Int {
        return albums.count
    }
    
    func album(at indexPath: IndexPath) -> TTAAlbum {
        return albums[indexPath.row]
    }
}

// MARK: - Action

extension TTAAlbumPickerViewController {
    
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource

extension TTAAlbumPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TTAAlbumTableViewCell.self)", for: indexPath) as! TTAAlbumTableViewCell
        cell.album = album(at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TTAAlbumPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let splitViewController = splitViewController else { return }
        guard let pickerController = assetPickerController.topViewController as? TTAAssetPickerViewController else { return }
        pickerController.album = album(at: indexPath)
        splitViewController.showDetailViewController(assetPickerController, sender: nil)
    }
}
