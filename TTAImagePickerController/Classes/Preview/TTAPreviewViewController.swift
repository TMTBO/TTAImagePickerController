//
//  TTAPreviewViewController.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

protocol TTAPreviewViewControllerDelegate: class {
    func previewViewController(_ previewVc: TTAPreviewViewController, backToAssetPickerControllerWith currentIndex: Int, selectedAsset: [PHAsset])
    func previewViewController(_ previewVc: TTAPreviewViewController, didFinishPicking assets: [PHAsset])
}

public class TTAPreviewViewController: UIViewController, TTAImagePickerControllerCompatiable {

    weak var delegate: TTAPreviewViewControllerDelegate?
    /// Only for preview selected assets from outer
    fileprivate weak var previewDelegate: TTAImagePickerControllerDelegate?
    
    var allowDeleteImage = false
    var selectItemTintColor: UIColor?
    var tintColor: UIColor?
    
    internal var selected: [PHAsset]
    internal let maxPickerNum: Int
    fileprivate var previewAssets: [PHAsset]
    internal var currentIndex: Int {
        didSet {
            if canScrollToCurrentIndex {
                scroll(to: currentIndex)
            }
        }
    }
    internal var canScrollToCurrentIndex: Bool = false
    
    internal var album: TTAAlbum? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAPreviewCollectionViewLayout())
    fileprivate let previewNavigationBar = TTAPreviewNavigationBar()
    fileprivate let previewToolBar = TTAPreviewToolBar()
    fileprivate var isHiddenStatusBar = false
    fileprivate var isHiddenBars = false
    
    init(album: TTAAlbum?, selected: [PHAsset], maxPickerNum: Int, index: Int) {
        self.album = album
        self.selected = selected
        self.previewAssets = selected
        self.maxPickerNum = maxPickerNum
        self.currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(selected: [TTAAsset], index: Int, delegate: TTAImagePickerControllerDelegate?) {
        self.init(album: nil, selected: selected.map { $0.original }, maxPickerNum: selected.count, index: index)
        previewDelegate = delegate
        TTACachingImageManager.prepareCachingManager()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if previewDelegate != nil {
            TTACachingImageManager.destoryCachingManager()
        }
        #if DEBUG
            print("TTAImagePickerController >>>>>> preview controller deinit")
        #endif
    }
    
}

// MARK: - Life Cycle

extension TTAPreviewViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        scroll(to: currentIndex)
        configBars()
        updateCounter()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.orientationDidChanged()
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UI

fileprivate extension TTAPreviewViewController {
    func setupUI() {
        createViews()
        configViews()
        _ = updateBars(isHidden: isHiddenBars)
    }
    
    func createViews() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        view.addSubview(previewNavigationBar)
        view.addSubview(previewToolBar)
    }
    
    func configViews() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        previewNavigationBar.delegate = self
        previewNavigationBar.selectItemTintColor = selectItemTintColor
        previewNavigationBar.tintColor = tintColor
        previewNavigationBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        previewNavigationBar.configHideSelectButton(maxPickerNum <= 1)
        
        previewToolBar.delegate = self
        previewToolBar.selectItemTintColor = selectItemTintColor
        previewToolBar.tintColor = tintColor
        previewToolBar.allowDeleteImage = allowDeleteImage
        previewToolBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        prepareCollectionView()
    }
    
    func layoutViews() {
        var navigationBarHeight: CGFloat = 20
        var layoutMaxY = view.bounds.height
        if #available(iOS 11.0, *) {
            let rect = view.safeAreaLayoutGuide.layoutFrame
            navigationBarHeight = rect.minY
            layoutMaxY = rect.maxY
        }
        let addition = view.bounds.height - layoutMaxY
        
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width + 30, height: view.bounds.height)
        previewNavigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: TTAPreviewNavigationBar.height(with: navigationBarHeight))
        previewToolBar.frame = CGRect(x: 0,
                                      y: layoutMaxY - TTAPreviewToolBar.height(with: 0),
                                      width: view.bounds.width,
                                      height: TTAPreviewToolBar.height(with: addition))
        let layout = collectionView.collectionViewLayout as? TTAPreviewCollectionViewLayout
        layout?.itemSize = collectionView.bounds.size
    }
    
    func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.register(TTAPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "\(TTAPreviewCollectionViewCell.self)")
    }
    
    func updateStatusBarApperance(isHidden: Bool) {
        guard isHiddenStatusBar != isHidden else { return }
        isHiddenStatusBar = isHidden
        setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.isStatusBarHidden = isHidden
    }
    
    func configBars() {
        let isSelected: Bool
        let isShowPreviewVideo: Bool
        if let currentAsset = asset(at: IndexPath(item: currentIndex, section: 0)) {
            isSelected = selected.contains(currentAsset)
            isShowPreviewVideo = currentAsset.isVideo
            previewNavigationBar.updateImageInfo(with: currentAsset.creationDate)
        } else {
            isSelected = false
            isShowPreviewVideo = false
        }
        previewNavigationBar.configNavigationBar(isSelected: isSelected)
        previewToolBar.showVideoPreviewOrNot(isShowPreviewVideo)
    }
    
    func updateBars(isHidden: Bool) {
        guard isHiddenBars != isHidden else { return}
        previewNavigationBar.isHidden = isHidden
        previewToolBar.isHidden = isHidden
        isHiddenBars = isHidden
        updateStatusBarApperance(isHidden: isHidden)
    }
    
    func scroll(to index: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .right, animated: false)            
        }
    }
    
    func setup(assetCell cell: TTAPreviewCollectionViewCell, indexPath: IndexPath) {
        let tag = indexPath.item + 1
        cell.configCell(tag: tag, delegate: self, isHiddenBars: isHiddenBars)
        TTAImagePickerManager.fetchPreview(for: asset(at: indexPath), progressHandler: { (progress, error, stop, info) in
            guard cell.tag == tag else { return }
            cell.updateProgress(progress, error: error)
        }) { (fetchResult) in
            guard cell.tag == tag else { return }
            cell.configResult(fetchResult)
        }
    }
}

// MARK: - Data

fileprivate extension TTAPreviewViewController {
    
    func assetCount() -> Int {
        guard let album = album else { return previewAssets.count }
        return album.assets.count
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset? {
        guard let album = album else { return previewAssets[indexPath.item] }
        return album.asset(at: indexPath.item)
    }
    
    func asset(for cell: UICollectionViewCell) -> PHAsset? {
        guard let indexPath = collectionView.indexPath(for: cell),
            let operateAsset = asset(at: indexPath) else { return nil }
        return operateAsset
    }
}

// MARK: - Actions

extension TTAPreviewViewController {
    func orientationDidChanged() {
        guard let cell = collectionView.visibleCells.first as? TTAPreviewCollectionViewCell else { return }
        cell.orientationDidChanged()
    }
}

// MARK: - UICollectionViewDataSource

extension TTAPreviewViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTAPreviewCollectionViewCell.self)", for: indexPath) as! TTAPreviewCollectionViewCell
        setup(assetCell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TTAPreviewViewController: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetWidth = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let index: Int = Int(offsetWidth / (view.bounds.width + 30))
        if index < assetCount() && currentIndex != index {
            currentIndex = index
            configBars()
        }
    }
}

// MARK: - TTAPreviewNavigationBarDelegate

extension TTAPreviewViewController: TTAPreviewNavigationBarDelegate {
    
    func canOperate() -> (canOperate: Bool, asset: PHAsset?) {
        guard let cell = collectionView.visibleCells.first,
            let operateAsset = asset(for: cell) else { return (false, nil) }
        return (canOperateAsset(operateAsset), operateAsset)
    }
    
    @objc func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, didClickBack button: UIButton) {
        delegate?.previewViewController(self, backToAssetPickerControllerWith: currentIndex, selectedAsset: selected)
        guard let navigationController = navigationController else {
            dismiss(animated: true, completion: nil)
            return
        }
        if navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, asset: PHAsset, isSelected: Bool) {
        operateAsset(asset, isSelected: isSelected)
    }
}

// MARK: - TTAPreviewToolBarDelegate

extension TTAPreviewViewController: TTAPreviewToolBarDelegate {
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDone button: UIButton) {
        if maxPickerNum == 1, let asset = asset(at: IndexPath(item: currentIndex, section: 0)) {
            selected = [asset]
        }
        delegate?.previewViewController(self, didFinishPicking: selected)
        if previewDelegate != nil {
            fetchImages(with: selected, completionHandler: { [weak self] (images) in
                guard let `self` = self else { return }
                self.previewDelegate?.imagePickerController(self,
                                                            didFinishPicking: images,
                                                            assets: self.selected.map { TTAAsset(asset: $0) })
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickVideoPreview button: UIButton) {
        guard let asset = asset(at: IndexPath(item: currentIndex, section: 0)) else { return }
        let videoPreviewVc = TTAVideoPreviewViewController(asset: asset)
        navigationController?.pushViewController(videoPreviewVc, animated: true)
    }
    
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDelete button: UIButton) {
        guard let asset = asset(at: IndexPath(item: currentIndex, section: 0)) else { return }
        TTAImagePickerManager.delete(asset: asset) { [weak self] (isSuccess) in
            #if DEBUG
                print("Delete PHAssets \(isSuccess ? "Success" : "Failed")!")
            #endif
            guard isSuccess,
                let `self` = self else { return }
            if self.selected.contains(asset),
                let index = self.selected.firstIndex(of: asset) {
                self.selected.remove(at: index)
                self.updateCounter()
                if self.album == nil {
                    self.previewAssets.remove(at: index)
                    if self.assetCount() <= 0 {
                        self.perform(#selector(self.previewNavigationBar(_:didClickBack:)),
                                     with: self.previewNavigationBar,
                                     with: nil)
                        return
                    }
                }
            }
            self.currentIndex = self.currentIndex > 0 ? self.currentIndex - 1 : 0
            self.configBars()
        }
    }
}

// MARK: - TTAPreviewCollectionViewCellDelegate

extension TTAPreviewViewController: TTAPreviewCollectionViewCellDelegate {
    func tappedPreviewCell(_ cell: TTAPreviewCollectionViewCell) {
        updateBars(isHidden: !isHiddenBars)
        cell.configCell(isHiddenBars: isHiddenBars)
        let reloadItems = collectionView.nearIndexPaths(for: cell, in: 0, sideCount: 1)
        collectionView.reloadItems(at: reloadItems)
    }
}

// MARK: - TTAOperateAssetProtocol

extension TTAPreviewViewController: TTAOperateAssetProtocol {
    func updateCounter() {
        previewToolBar.update(count: selected.count, with: maxPickerNum <= 1)
    }
}
