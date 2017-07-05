//
//  TTAPreviewViewController.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

class TTAPreviewViewController: UIViewController {
    
    var selectItemTintColor: UIColor?
    
    fileprivate let album: TTAAlbum
    fileprivate var selected: [PHAsset]
    fileprivate let maxPickerNum: Int
    fileprivate var currentIndexPath: IndexPath
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAPreviewCollectionViewLayout())
    fileprivate let previewNavigationBar = TTAPreviewNavigationBar()
    fileprivate let previewToolBar = TTAPreviewToolBar()
    fileprivate var isHiddenStatusBar = true
    fileprivate var isHiddenToolBars = false
    
    init(album: TTAAlbum, selected: [PHAsset], maxPickerNum: Int, indexPath: IndexPath) {
        self.album = album
        self.selected = selected
        self.maxPickerNum = maxPickerNum
        self.currentIndexPath = indexPath
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
        scrollTo(indexPath: currentIndexPath)
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
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width + 30, height: UIScreen.main.bounds.height)
        previewNavigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64)
        previewToolBar.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
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
    
    func updateToolBars(isHidden: Bool) -> Bool {
        guard isHiddenToolBars != isHidden else { return false }
        previewNavigationBar.isHidden = isHidden
        previewToolBar.isHidden = isHidden
        isHiddenToolBars = isHidden
        return true
    }
    
    func scrollTo(indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
    }
    
    func setup(assetCell cell: TTAPreviewCollectionViewCell, indexPath: IndexPath) {
        currentIndexPath = indexPath
        cell.delegate = self
        cell.configImage()
        let tag = indexPath.item + 1
        cell.tag = tag
        album.requestThumbnail(with: indexPath.item, size: cell.bounds.size) { (image) in
            if cell.tag != tag { return }
            cell.configImage(with: image)
        }
        let isSelected: Bool
        if let currentAsset = album.asset(at: indexPath.item) {
            isSelected = selected.contains(currentAsset)
        } else {
            isSelected = false
        }
        previewNavigationBar.configNavigationBar(isSelected: isSelected)
    }
}

// MARK: - Data

extension TTAPreviewViewController {
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TTAPreviewCollectionViewCell.self)", for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TTAPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TTAPreviewCollectionViewCell else { return }
        setup(assetCell: cell, indexPath: indexPath)
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
        navigationController?.popViewController(animated: true)
    }
    
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, asset: PHAsset, isSelected: Bool) {
        operateAsset(asset, isSelected: isSelected)
    }
}

extension TTAPreviewViewController: TTAPreviewToolBarDelegate {
    func previewToolBar(toolBar: TTAPreviewToolBar, didClick doneButton: UIButton) {
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
