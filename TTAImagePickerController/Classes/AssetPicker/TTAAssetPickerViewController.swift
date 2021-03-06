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
    
    var allowDeleteImage = false
    var allowTakePicture = true
    
    /// The max num image of the image picker can pick, default is 9
    var maxPickerNum = 9 {
        didSet {
            canSelect = !(maxPickerNum <= 1)
        }
    }
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    var selectItemTintColor: UIColor?
    
    /// The asset that already seleted
    var selected: [PHAsset] = [] {
        didSet {
            selected = selected.filter { album.isContain($0) }
        }
    }
    
    var album: TTAAlbum! {
        willSet {
            TTACachingImageManager.stopCachingImagesForAllAssets()
        }
        didSet {
            navigationItem.title = album.albumInfo.name
            collectionView.reloadData()
            scrollTo(assetCount() - 1)
            imagePreviewViewController?.album = imagePreviewViewController?.album == nil ? nil : album
            startCaching()
        }
    }
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAAssetCollectionViewLayout())
    fileprivate var deleteItem = UIBarButtonItem()
    fileprivate var previewItem = UIBarButtonItem()
    fileprivate var doneItem = UIBarButtonItem()
    fileprivate var countLabel = TTASelectCountLabel()
    fileprivate var canSelect = true
    
    fileprivate var imagePreviewViewController: TTAPreviewViewController?
    
    init(album: TTAAlbum, selectedAsset: [PHAsset]) {
        self.album = album
        self.selected = selectedAsset
        super.init(nibName: nil, bundle: nil)
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
        collectionView.register(TTACameraCell.self, forCellWithReuseIdentifier: "\(TTACameraCell.self)")
    }
    
    func prepareCancelItem() {
        if UIDevice.current.userInterfaceIdiom == .pad { return }
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelItem))
        self.navigationItem.rightBarButtonItem = cancelItem
    }
    
    func prepareToolBar() {
        previewItem = UIBarButtonItem(title: Bundle.localizedString(for: "Preview"), style: .plain, target: self, action: #selector(didClickPreviewItem))
        previewItem.isEnabled = false
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didClickDeleteItem))
        deleteItem.isEnabled = false
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didClickDoneItem))
        doneItem.isEnabled = false
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let countLabelWH = (navigationController?.toolbar.bounds.height ?? 49) - 23
        countLabel = TTASelectCountLabel(frame: CGRect(x: 0, y: 0, width: countLabelWH, height: countLabelWH))
        countLabel.selectItemTintColor = selectItemTintColor
        let countItem = UIBarButtonItem(customView: countLabel)
        var toolBarItems = [previewItem, spaceItem, countItem, doneItem]
        if allowDeleteImage {
            toolBarItems.insert(deleteItem, at: 0)
        }
        self.toolbarItems = toolBarItems
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
            let previewAlbum = isPreview ? nil : album
            if let imagePreviewViewController = imagePreviewViewController {
                imagePreviewViewController.album = previewAlbum
                imagePreviewViewController.canScrollToCurrentIndex = true
                imagePreviewViewController.currentIndex = index
                imagePreviewViewController.canScrollToCurrentIndex = false
            } else {
                imagePreviewViewController = TTAPreviewViewController(album: previewAlbum,
                                                                      selected: selected,
                                                                      maxPickerNum: maxPickerNum,
                                                                      index: index)
                imagePreviewViewController?.delegate = self
                imagePreviewViewController?.selectItemTintColor = selectItemTintColor
                imagePreviewViewController?.tintColor = navigationController?.navigationBar.tintColor
                imagePreviewViewController?.allowDeleteImage = allowDeleteImage
            }
            previewVc = imagePreviewViewController!
        }
        navigationController?.pushViewController(previewVc, animated: true)
    }
    
    func showCameraViewController() {
        func permissionDenied() {
            showPermissionView(with: .camera)
        }
        
        func showCamera() {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let photoTaker = UIImagePickerController()
            photoTaker.delegate = self
            photoTaker.sourceType = .camera
            present(photoTaker, animated: true, completion: nil)
        }
        
        TTAImagePickerManager.checkCameraPermission { (isAuthorized) in
            isAuthorized ? showCamera() : permissionDenied()
        }
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
        TTACachingImageManager.startCachingImages(for: album.assets,
                                                          targetSize: layout.itemSize,
                                                          contentMode: nil,
                                                          options: nil)
    }
    
}

// MARK: - Actions

extension TTAAssetPickerViewController {
    @objc func didClickCancelItem() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didClickPreviewItem() {
        showPreviewViewController(from: 0, isPreview: true)
    }
    
    @objc func didClickDeleteItem() {
        TTAImagePickerManager.delete(assets: selected) { [weak self] (isSuccess) in
            if isSuccess {
                self?.selected.removeAll()
                self?.updateCounter()
            }
            #if DEBUG
                print("Delete PHAssets \(isSuccess ? "Success" : "Failed")!")
            #endif
        }
    }
    
    @objc func didClickDoneItem() {
        delegate?.assetPickerController(self, didFinishPicking: selected)
    }
}

// MARK: - UICollectionViewDataSource

extension TTAAssetPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount() + (allowTakePicture && album.albumInfo.canShowCamera ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard allowTakePicture && album.albumInfo.canShowCamera && indexPath.item == assetCount() else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTAAssetCollectionViewCell.self)", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTACameraCell.self)", for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TTAAssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard !allowTakePicture || indexPath.item < assetCount() else {
            showCameraViewController()
            return
        }
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
        deleteItem.isEnabled = selected.count > 0
        doneItem.isEnabled = selected.count > 0
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension TTAAssetPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else { return }
        TTAImagePickerManager.save(image: image) { (isSuccess) in
            #if DEBUG
                print("Take photo and Save \(isSuccess ? "Successed" : "Failed")!")
            #endif
        }
    }
}
