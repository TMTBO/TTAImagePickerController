//
//  TTAAssetPickerViewController.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

protocol TTAAssetPickerViewControllerDelegate: class {
    func assetPickerController(_ picker: TTAAssetPickerViewController, didFinishPicking assets: [PHAsset])
}

class TTAAssetPickerViewController: UIViewController {
    
    weak var delegate: TTAAssetPickerViewControllerDelegate?
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9 {
        didSet {
            canSelect = !(maxPickerNum <= 1)
        }
    }
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor?
    
    /// The asset that already seleted
    public var selected: [PHAsset] = []
    
    var album: TTAAlbum! {
        willSet {
            TTACachingImageManager.shared?.stopCachingImagesForAllAssets()
        }
        didSet {
            navigationItem.title = album.albumInfo.name
            collectionView.reloadData()
            scrollTo(assetCount() - 1)
            startCaching()
        }
    }
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAAssetCollectionViewLayout())
    fileprivate var previewItem = UIBarButtonItem()
    fileprivate var doneItem = UIBarButtonItem()
    fileprivate var countLabel = TTASelectCountLabel()
    fileprivate var canSelect = true
    
    init(album: TTAAlbum, selectedAsset: [PHAsset]) {
        self.album = album
        self.selected = selectedAsset
        super.init(nibName: nil, bundle: nil)
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
        setupUI()
        scrollTo(self.assetCount() - 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = !canSelect
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

// MARK: - UI

fileprivate extension TTAAssetPickerViewController {
    
    func setupUI() {
        createViews()
        configViews()
        layoutViews()
        prepareCancelItem()
        prepareToolBar()
        startCaching()
    }
    
    func createViews() {
        view.addSubview(collectionView)
    }
    
    func configViews() {
        view.backgroundColor = .white
        navigationItem.title = album.albumInfo.name
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        prepareCollectionView()
    }
    
    func layoutViews() {
        collectionView.frame = view.bounds
    }
    
    func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(TTAAssetCollectionViewCell.self, forCellWithReuseIdentifier: "\(TTAAssetCollectionViewCell.self)")
    }
    
    func prepareCancelItem() {
        if UIDevice.current.userInterfaceIdiom == .pad { return }
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
    
    func prepareToolBar() {
        previewItem = UIBarButtonItem(title: Bundle.localizedString(for: "Preview"), style: .plain, target: self, action: #selector(didClickPreviewItem))
        previewItem.isEnabled = false
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didClickDoneItem))
        doneItem.isEnabled = false
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let countLabelWH = (navigationController?.toolbar.bounds.height ?? 49) - 23
        countLabel = TTASelectCountLabel(frame: CGRect(x: 0, y: 0, width: countLabelWH, height: countLabelWH))
        countLabel.selectItemTintColor = selectItemTintColor
        let countItem = UIBarButtonItem(customView: countLabel)
        self.toolbarItems = [previewItem, spaceItem, countItem, doneItem]
        updateCounter()
    }
    
    func scrollTo(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.assetCount() <= Int(TTAAssetCollectionViewLayout.TTAAssetCollectionViewLayoutConst.correctColumNum) { return }
//            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: false)
            
            guard let attribute = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else { return }
            let rect = attribute.frame
            let contentSize = self.collectionView.contentSize
            let bounds = self.collectionView.bounds

            let maxOffsetY = contentSize.height - bounds.height + (self.canSelect ? 44 : 0)
            let shouldOffsetY = rect.minY - bounds.height / 2 + rect.height
            let offsetY = min(maxOffsetY, shouldOffsetY)

            // Because of the NavigationBar, the `offsetY` should less or equal to -64
            if offsetY <= -64 { return }
            self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
    func setup(assetCell cell: TTAAssetCollectionViewCell, indexPath: IndexPath) {
        guard let currentAsset = asset(at: indexPath) else { return }
        let isSelected = selected.contains(currentAsset)
        let tag = indexPath.item + 1
        let assetConfig = TTAAssetConfig(asset: currentAsset,
                                         tag: tag,
                                         delegate: self,
                                         selectItemTintColor: selectItemTintColor,
                                         isSelected: isSelected,
                                         canSelect: canSelect)
        cell.configCell(with: assetConfig)
        album.requestThumbnail(with: indexPath.item, size: cell.bounds.size.toPixel()) { (image) in
            guard let image = image, cell.tag == tag else { return }
            cell.configImage(with: image)
        }
    }
    
    func lightupCell(with index: Int, isPreview: Bool) {
        let correctIndex = isPreview ? album.index(for: selected[index]) : index
        let indexPath = IndexPath(item: correctIndex, section: 0)
        scrollTo(correctIndex)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TTAAssetCollectionViewCell else { return }
        cell.lightUp()
    }
    
    func showPreviewViewController(from index: Int, isPreview: Bool) {
        guard let currentAsset = asset(at: IndexPath(item: index, section: 0)) else { return }
        let previewVc: UIViewController
        if currentAsset.isVideo {
            previewVc = TTAVideoPreviewViewController(asset: currentAsset)
        } else {
            let imagePreviewVc = TTAPreviewViewController(album: isPreview ? nil : album,
                                                     selected: selected,
                                                     maxPickerNum: maxPickerNum,
                                                     index: index)
            imagePreviewVc.delegate = self
            imagePreviewVc.selectItemTintColor = selectItemTintColor
            imagePreviewVc.tintColor = navigationController?.navigationBar.tintColor
            previewVc = imagePreviewVc
        }
        navigationController?.pushViewController(previewVc, animated: true)
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
    
    func startCaching() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        TTACachingImageManager.shared?.startCachingImages(for: album.assets,
                                                          targetSize: layout.itemSize,
                                                          contentMode: nil,
                                                          options: nil)
    }
    
}

// MARK: - Actions

extension TTAAssetPickerViewController {
    func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
    
    func didClickPreviewItem() {
        showPreviewViewController(from: 0, isPreview: true)
    }
    
    func didClickDoneItem() {
        delegate?.assetPickerController(self, didFinishPicking: selected)
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
        showPreviewViewController(from: indexPath.item, isPreview: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TTAAssetCollectionViewCell else { return }
        setup(assetCell: cell, indexPath: indexPath)
    }
}

// MARK: - TTAAssetCollectionViewCellDelegate

extension TTAAssetPickerViewController: TTAAssetCollectionViewCellDelegate {
    func canOperateCell(cell: TTAAssetCollectionViewCell) -> (canOperate: Bool, asset: PHAsset?) {
        guard let operateAsset = asset(for: cell) else { return (false, nil) }
        return (canOperateAsset(operateAsset), operateAsset)
    }
    
    func assetCell(_ cell: TTAAssetCollectionViewCell, asset: PHAsset, isSelected: Bool) {
        operateAsset(asset, isSelected: isSelected)
    }
}

// MARK: - TTAPreviewViewControllerDelegate

extension TTAAssetPickerViewController: TTAPreviewViewControllerDelegate {
    
    func previewViewController(_ previewVc: TTAPreviewViewController, didFinishPicking assets: [PHAsset]) {
        delegate?.assetPickerController(self, didFinishPicking: assets)
    }
    
    func previewViewController(_ previewVc: TTAPreviewViewController, backToAssetPickerControllerWith currentIndex: Int, selectedAsset: [PHAsset]) {
        lightupCell(with: currentIndex, isPreview: previewVc.album == nil)
        guard self.selected != selectedAsset else { return }
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            let assets = Set(self.selected).symmetricDifference(Set(selectedAsset))
            let indexPaths = assets.map { IndexPath(item: self.album.index(for: $0), section: 0) }
            self.selected = selectedAsset
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: indexPaths)
                self.updateCounter()
            }
        }
    }
}

// MARK: - TTAOperateAssetProtocol

extension TTAAssetPickerViewController: TTAOperateAssetProtocol {
    func updateCounter() {
        countLabel.config(with: selected.count)
        previewItem.isEnabled = selected.count > 0
        doneItem.isEnabled = selected.count > 0
    }
}
