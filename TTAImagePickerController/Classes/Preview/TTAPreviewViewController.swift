//
//  TTAPreviewViewController.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

class TTAPreviewViewController: UIViewController {
    
    let album: TTAAlbum
    let selected: [PHAsset]
    let maxPickerNum: Int
    let indexPath: IndexPath
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TTAPreviewCollectionViewLayout())
    fileprivate var isHiddenStatusBar = true
    
    init(album: TTAAlbum, selected: [PHAsset], maxPickerNum: Int, indexPath: IndexPath) {
        self.album = album
        self.selected = selected
        self.maxPickerNum = maxPickerNum
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension TTAPreviewViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateStatusBarApperance(isHidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateStatusBarApperance(isHidden: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI

fileprivate extension TTAPreviewViewController {
    func setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
    }
    
    func _createViews() {
        view.backgroundColor = .clear
        
    }
    
    func _configViews() {
        automaticallyAdjustsScrollViewInsets = false
        _prepareCollectionView()
    }
    
    func _layoutViews() {
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width + 30, height: UIScreen.main.bounds.height)
    }
    
    func _prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.register(TTAPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "\(TTAPreviewCollectionViewCell.self)")
        view.addSubview(collectionView)
    }
    
    func updateStatusBarApperance(isHidden: Bool) {
        guard isHiddenStatusBar != isHidden else { return }
        isHiddenStatusBar = isHidden
        setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.isStatusBarHidden = isHidden
    }
    
    func setup(assetCell cell: TTAPreviewCollectionViewCell, indexPath: IndexPath) {
        cell.configImage()
        let tag = indexPath.item + 1
        cell.tag = tag
        album.requestThumbnail(with: indexPath.item, size: cell.bounds.size) { (image) in
            if cell.tag != tag { return }
            cell.configImage(with: image)
        }
//        let isSelected: Bool
//        if let currentAsset = album.asset(at: indexPath.item) {
//            isSelected = selected.contains(currentAsset)
//        } else {
//            isSelected = false
//        }
//        cell.configState(isSelected: isSelected)
    }
}

// MARK: - UICollectionViewDataSource

extension TTAPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
