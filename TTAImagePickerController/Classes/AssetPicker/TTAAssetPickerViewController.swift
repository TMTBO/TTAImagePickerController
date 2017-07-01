//
//  TTAAssetPickerViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

class TTAAssetPickerViewController: UIViewController {
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    /// The asset that already seleted
    public var selectedAsset: [PHAsset] = []
    
    var album: TTAAlbum! {
        willSet {
            TTACachingImageManager.shared?.stopCachingImagesForAllAssets()
        }
        didSet {
            navigationItem.title = album.name()
            collectionView.reloadData()
            _scrollToBottom()
            _startCaching()
        }
    }
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAAssetCollectionViewLayout())
    
    init(album: TTAAlbum, selectedAsset: [PHAsset]) {
        self.album = album
        self.selectedAsset = selectedAsset
        super.init(nibName: nil, bundle: nil)
        _prepareIconFont()
        TTACachingImageManager.prepareCachingManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TTACachingImageManager.destoryCachingManager()
        #if DEBUG
            print("TTAImagePickerController >>>>>> asset picker controller deinit")
        #endif
    }
    
}

// MARK: - Life Cycle

extension TTAAssetPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
        _scrollToBottom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

// MARK: - UI

fileprivate extension TTAAssetPickerViewController {
    
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
        _prepareCancelItem()
        _startCaching()
    }
    
    func _createViews() {
        view.addSubview(collectionView)
    }
    
    func _configViews() {
        view.backgroundColor = .white
        navigationItem.title = album.name()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        _prepareCollectionView()
    }
    
    func _layoutViews() {
        collectionView.frame = view.bounds
    }
    
    func _prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(TTAAssetCollectionViewCell.self, forCellWithReuseIdentifier: "\(TTAAssetCollectionViewCell.self)")
    }
    
    func _prepareCancelItem() {
        if UIDevice.current.userInterfaceIdiom == .pad { return }
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
    
    func _prepareIconFont() {
        guard let path = Bundle(for: TTAImagePickerController.self).path(forResource: "TTAImagePickerController", ofType: "bundle"),
            let bundle = Bundle(path: path),
            let url = bundle.url(forResource: "iconfont", withExtension: ".ttf") else { return }
        UIFont.registerFont(with: url, fontName: "iconfont")
    }
    
    func _scrollToBottom() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.assetCount() <= Int(TTAAssetCollectionViewLayout.TTAAssetCollectionViewLayoutConst.correctColumNum) { return }
            self.collectionView.scrollToItem(at: IndexPath(item: self.assetCount() - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    func setup(assetCell cell: TTAAssetCollectionViewCell, indexPath: IndexPath) {
        cell.delegate = self
        cell.configImage()
        let tag = indexPath.item + 1
        cell.tag = tag
        album.requestThumbnail(with: indexPath.item, size: cell.bounds.size) { (image) in
            if cell.tag != tag { return }
            cell.configImage(with: image)
        }
        let isSelected: Bool
        if let currentAsset = asset(at: indexPath) {
            isSelected = selectedAsset.contains(currentAsset)
        } else {
            isSelected = false
        }
        cell.configState(isSelected: isSelected)
    }
}

// MARK: - Data

extension TTAAssetPickerViewController {
    
    func assetCount() -> Int {
        return album.assets.count
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset? {
        return album.asset(at: indexPath.item)
    }
    
    func asset(for cell: UICollectionViewCell) -> PHAsset? {
        guard let indexPath = collectionView.indexPath(for: cell),
            let operateAsset = asset(at: indexPath) else { return nil }
        return operateAsset
    }
    
    func canOperateAsset(_ asset: PHAsset) -> Bool {
        guard !selectedAsset.contains(asset) else { return true }
        if selectedAsset.count >= maxPickerNum {
            return false
        }
        return true
    }
    
    func operateAsset(_ asset: PHAsset, isSelected: Bool) {
        if isSelected {
            selectedAsset.append(asset)
        } else {
            guard let index = selectedAsset.index(of: asset) else { return }
            selectedAsset.remove(at: index)
        }
    }
    
    func _startCaching() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        TTACachingImageManager.shared?.startCachingImages(for: album.assets, targetSize: layout.itemSize, contentMode: nil, options: nil)
    }
    
}

// MARK: - Actions

extension TTAAssetPickerViewController {
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTAAssetCollectionViewCell.self)", for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TTAAssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TTAAssetCollectionViewCell else { return }
        setup(assetCell: cell, indexPath: indexPath)
    }
}

// MARK: - TTAAssetCollectionViewCellDelegate

extension TTAAssetPickerViewController: TTAAssetCollectionViewCellDelegate {
    func canOperateCell(cell: TTAAssetCollectionViewCell) -> Bool {
        guard let operateAsset = asset(for: cell) else { return false }
        return canOperateAsset(operateAsset)
    }
    
    func assetCell(_ cell: TTAAssetCollectionViewCell, isSelected: Bool) {
        guard let operationAsset = asset(for: cell) else { return }
        operateAsset(operationAsset, isSelected: isSelected)
    }
}
