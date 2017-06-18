//
//  TTAAssetPickerViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAssetPickerViewController: UIViewController {
    
    struct AssetPickerViewControllerConst {
        static let assetCollectionViewCellIdentifer = "assetCollectionViewCellIdentifer"
    }
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAAssetCollectionViewLayout())
    
    fileprivate let collection: TTAAssetCollection!
    
    init(collection: TTAAssetCollection) {
        self.collection = collection
        super.init(nibName: nil, bundle: nil)
        _prepareIconFont()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension TTAAssetPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
    
}
// MARK: - UI

extension TTAAssetPickerViewController {
    
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
    }
    
    func _createViews() {
        view.addSubview(collectionView)
    }
    
    func _configViews() {
        view.backgroundColor = .white
        navigationItem.title = collection.assetCollectionName
        
        _prepareCollectionView()
    }
    
    func _layoutViews() {
        collectionView.frame = view.bounds
    }
    
    func _prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(TTAAssetCollectionViewCell.self, forCellWithReuseIdentifier: TTAAssetPickerViewController.AssetPickerViewControllerConst.assetCollectionViewCellIdentifer)
    }
    
    func _prepareIconFont() {
        guard let path = Bundle(for: TTAImagePickerController.self).path(forResource: "TTAImagePickerController", ofType: "bundle"),
            let bundle = Bundle(path: path),
            let url = bundle.url(forResource: "iconfont", withExtension: ".ttf") else { return }
        UIFont.registerFont(with: url, fontName: "iconfont")
    }
}

// MARK: - Data

extension TTAAssetPickerViewController {
    
    func assetCount() -> Int {
        return collection.assets.count
    }
    
    func asset(at indexPath: IndexPath) -> TTAAsset {
        return TTAAsset(originalAsset: collection.assets[indexPath.item])
    }
}

// MARK: - UICollectionViewDataSource

extension TTAAssetPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TTAAssetPickerViewController.AssetPickerViewControllerConst.assetCollectionViewCellIdentifer, for: indexPath) as! TTAAssetCollectionViewCell
        cell.asset = asset(at: indexPath)
        return cell
    }
}

extension TTAAssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO: Add Cache
    }
}
