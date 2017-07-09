//
//  TTAPreviewViewController.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

protocol TTAPreviewViewControllerDelegate: class {
    func previewViewController(_ previewVc: TTAPreviewViewController, backToAssetPickerControllerWith selectedAsset: [PHAsset])
    func previewViewController(_ previewVc: TTAPreviewViewController, didFinishPicking assets: [PHAsset])
}

class TTAPreviewViewController: UIViewController {
    
    weak var delegate: TTAPreviewViewControllerDelegate?
    var selectItemTintColor: UIColor?
    
    fileprivate let album: TTAAlbum?
    fileprivate var selected: [PHAsset]
    fileprivate let maxPickerNum: Int
    fileprivate var currentIndex: Int
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAPreviewCollectionViewLayout())
    fileprivate let previewNavigationBar = TTAPreviewNavigationBar()
    fileprivate let previewToolBar = TTAPreviewToolBar()
    fileprivate var isHiddenStatusBar = true
    fileprivate var isHiddenToolBars = false
    
    init(album: TTAAlbum?, selected: [PHAsset], maxPickerNum: Int, index: Int) {
        self.album = album
        self.selected = selected
        self.maxPickerNum = maxPickerNum
        self.currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
            print("TTAImagePickerController >>>>>> preview controller deinit")
        #endif
    }
    
}

// MARK: - Life Cycle

extension TTAPreviewViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        scroll(to: currentIndex)
        updateNavigationBar()
        updateCounter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        updateStatusBarApperance(isHidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        updateStatusBarApperance(isHidden: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
}

// MARK: - UI

fileprivate extension TTAPreviewViewController {
    func setupUI() {
        _createViews()
        _configViews()
        layoutViews()
        _ = updateToolBars(isHidden: isHiddenToolBars)
    }
    
    func _createViews() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        view.addSubview(previewNavigationBar)
        view.addSubview(previewToolBar)
    }
    
    func _configViews() {
        automaticallyAdjustsScrollViewInsets = false
        previewNavigationBar.delegate = self
        previewNavigationBar.selectItemTintColor = selectItemTintColor
        previewNavigationBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        previewToolBar.delegate = self
        previewToolBar.selectItemTintColor = selectItemTintColor
        previewToolBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _prepareCollectionView()
    }
    
    func layoutViews() {
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width + 30, height: view.bounds.height)
        previewNavigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64)
        previewToolBar.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
        let layout = collectionView.collectionViewLayout as? TTAPreviewCollectionViewLayout
        layout?.itemSize = collectionView.bounds.size
    }
    
    func _prepareCollectionView() {
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
    
    func updateCounter() {
        previewToolBar.update(count: selected.count)
    }
    
    func updateNavigationBar() {
        let isSelected: Bool
        if let currentAsset = asset(at: IndexPath(item: currentIndex, section: 0)) {
            isSelected = selected.contains(currentAsset)
        } else {
            isSelected = false
        }
        previewNavigationBar.configNavigationBar(isSelected: isSelected)
    }
    
    func updateToolBars(isHidden: Bool) -> Bool {
        guard isHiddenToolBars != isHidden else { return false }
        previewNavigationBar.isHidden = isHidden
        previewToolBar.isHidden = isHidden
        isHiddenToolBars = isHidden
        return true
    }
    
    func scroll(to index: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .right, animated: false)            
        }
    }
    
    func setup(assetCell cell: TTAPreviewCollectionViewCell, indexPath: IndexPath) {
        let tag = indexPath.item + 1
        cell.tag = tag
        cell.delegate = self
        cell.configImage()
        TTAImagePickerManager.fetchPreviewImage(for: asset(at: indexPath), progressHandler: { (progress, error, stop, info) in
            guard cell.tag == tag else { return }
            cell.updateProgress(progress, error: error)
        }) { (image) in
            guard let image = image, cell.tag == tag else { return }
            cell.configImage(with: image)
        }
    }
}

// MARK: - Data

extension TTAPreviewViewController {
    
    func assetCount() -> Int {
        guard let album = album else { return selected.count }
        return album.assets.count
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset? {
        guard let album = album else { return selected[indexPath.item] }
        return album.asset(at: indexPath.item)
    }
    
    func asset(for cell: UICollectionViewCell) -> PHAsset? {
        guard let indexPath = collectionView.indexPath(for: cell),
            let operateAsset = asset(at: indexPath) else { return nil }
        return operateAsset
    }
    
    func canOperateAsset(_ asset: PHAsset) -> Bool {
        guard !selected.contains(asset) else { return true }
        if selected.count >= maxPickerNum {
            return false
        }
        return true
    }
    
    func operateAsset(_ asset: PHAsset, isSelected: Bool) {
        if isSelected {
            selected.append(asset)
        } else {
            guard let index = selected.index(of: asset) else { return }
            selected.remove(at: index)
        }
        updateCounter()
    }
}

// MARK: - UICollectionViewDataSource

extension TTAPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTAPreviewCollectionViewCell.self)", for: indexPath) as! TTAPreviewCollectionViewCell
        setup(assetCell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TTAPreviewViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetWidth = scrollView.contentOffset.x
        let index: Int = Int(offsetWidth / (view.bounds.width + 30))
        if index < assetCount() && currentIndex != index {
            currentIndex = index
            updateNavigationBar()
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
    
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, didClickBack button: UIButton) {
        delegate?.previewViewController(self, backToAssetPickerControllerWith: selected)
        navigationController?.popViewController(animated: true)
    }
    
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, asset: PHAsset, isSelected: Bool) {
        operateAsset(asset, isSelected: isSelected)
    }
}

// MARK: - TTAPreviewToolBarDelegate

extension TTAPreviewViewController: TTAPreviewToolBarDelegate {
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDone button: UIButton) {
        delegate?.previewViewController(self, didFinishPicking: selected)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TTAPreviewCollectionViewCellDelegate

extension TTAPreviewViewController: TTAPreviewCollectionViewCellDelegate {
    func tappedPreviewCell(_ cell: TTAPreviewCollectionViewCell) {
        let isUpdated = updateToolBars(isHidden: !isHiddenToolBars)
        cell.configBackgroundColor(isChange: isUpdated)
    }
}
