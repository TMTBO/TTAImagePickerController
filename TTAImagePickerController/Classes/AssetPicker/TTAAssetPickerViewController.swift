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
    
    var collection: TTAAssetCollection! {
        didSet {
            navigationItem.title = collection.assetCollectionName
            collectionView.reloadData()
        }
    }
    
    // MARK: - Asset Caching
    
    var previousPreheatRect = CGRect.zero
    
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
        _scrollToBottom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _updateCachedAssets()
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
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(TTAAssetCollectionViewCell.self, forCellWithReuseIdentifier: TTAAssetPickerViewController.AssetPickerViewControllerConst.assetCollectionViewCellIdentifer)
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
            if self.assetCount() <= TTAImagePickerManager.shared.columnNum { return }
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
        return TTAAsset(originalAsset: collection.assets[indexPath.item])
    }
}

// MARK: - Asset Caching

extension TTAAssetPickerViewController {
    
    fileprivate func resetCachedAssets() {
        TTAImagePickerManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = .zero
    }
    
    func _updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil && collection != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect, hidesCamera: false) }
            .map { indexPath in collection.assets[collection.assets.count - indexPath.item - 1]}
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect, hidesCamera: false) }
            .map { indexPath in collection.assets[collection.assets.count - indexPath.item - 1] }
        
        // Update the assets the PHCachingImageManager is caching.
        TTAImagePickerManager.startCachingImages(for: addedAssets, targetSize: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionSize, contentMode: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionContentMode, options: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionRequestOptions)
        TTAImagePickerManager.stopCachingImages(for: removedAssets, targetSize: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionSize, contentMode: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionContentMode, options: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionRequestOptions)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TTAAssetPickerViewController.AssetPickerViewControllerConst.assetCollectionViewCellIdentifer, for: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TTAAssetCollectionViewCell,
            let requestID = cell.asset.requestID else { return }
        TTAImagePickerManager.cancelImageRequest(requestID)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _updateCachedAssets()
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension TTAAssetPickerViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        _ = indexPaths.map { indexPath in
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        _ = indexPaths.map({ indexPath in
        })
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
