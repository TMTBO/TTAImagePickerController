//
//  TTAAssetPickerViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

class TTAAssetPickerViewController: UIViewController {
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAAssetCollectionViewLayout())
    
    /// The number of the image picker pre row, default is 4
    var columnNum = 4
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    var collection: TTAAssetCollection! {
        willSet {
            TTACachingImageManager.shared?.stopCachingImagesForAllAssets()
        }
        didSet {
            navigationItem.title = collection.assetCollectionName
            collectionView.reloadData()
            _scrollToBottom()
            _startCaching()
        }
    }
    
    init(collection: TTAAssetCollection) {
        self.collection = collection
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

extension TTAAssetPickerViewController {
    
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
        _startCaching()
    }
    
    func _createViews() {
        view.addSubview(collectionView)
    }
    
    func _configViews() {
        view.backgroundColor = .white
        navigationItem.title = collection.assetCollectionName
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
    
    func _prepareIconFont() {
        guard let path = Bundle(for: TTAImagePickerController.self).path(forResource: "TTAImagePickerController", ofType: "bundle"),
            let bundle = Bundle(path: path),
            let url = bundle.url(forResource: "iconfont", withExtension: ".ttf") else { return }
        UIFont.registerFont(with: url, fontName: "iconfont")
    }
    
    func _scrollToBottom() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.assetCount() <= self.columnNum { return }
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            let bounds = self.collectionView.bounds
            let offsetY = contentSize.height - bounds.height
            
            // Because of the NavigationBar, the `offsetY` should less or equal to -64
            if offsetY <= -64 { return }
            self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
}

// MARK: - Data

extension TTAAssetPickerViewController {
    
    func assetCount() -> Int {
        return collection.assets.count
    }
    
    func asset(at indexPath: IndexPath) -> TTAAsset {
        return collection.assets[indexPath.item]
    }
    
    func _startCaching() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        TTACachingImageManager.shared?.startCachingImages(for: collection.assets, targetSize: layout.itemSize, contentMode: nil, options: nil)
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
        cell.asset = asset(at: indexPath)
    }
}

private extension UICollectionView {
    
    func indexPathsForElements(in rect: CGRect, hidesCamera: Bool) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        
        if hidesCamera {
            return allLayoutAttributes.map { $0.indexPath }
        } else {
            return allLayoutAttributes.flatMap { $0.indexPath.item == 0 ? nil : IndexPath(item: $0.indexPath.item - 1, section: $0.indexPath.section) }
        }
    }
    
}
