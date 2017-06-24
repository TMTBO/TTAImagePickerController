//
//  TTAAssetCollectionViewCell.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 17/06/2017.
//

import Photos

class TTAAssetCollectionViewCell: UICollectionViewCell {
    
    struct AssetCollectionViewCellConst {
        static let selectButtonMargin: CGFloat = 3
        static let selectButtonHeight: CGFloat = 26
        static let selectButtonWidth: CGFloat = selectButtonHeight
    }
    
    var imageRequestID: PHImageRequestID = 0
    var assetID: String = ""
    
    fileprivate let imageView = UIImageView()
    fileprivate let selectButton = TTASelectButton()
    
    var asset: TTAAsset! {
        didSet {
            imageView.image = nil
            
            let identifier = asset.assetID
            assetID = identifier
            asset.requestThumbnail(for: contentView.bounds.size) { [weak self] (image) in
                guard let `self` = self else { return }
                // `identifier` and `self.asset.assetID` were captured at different time, so they may got different value, to avoid the cell load anther image when scroll too fast
                if identifier == self.asset.assetID {
                    self.imageView.image = image
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutViews()
    }
    
}

// MARK: - UI

extension TTAAssetCollectionViewCell {
    func _setupUI() {
        _createViews()
        _configViews()
        _layoutViews()
    }
    
    func _createViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectButton)
    }
    
    func _configViews() {
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        selectButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        selectButton.addTarget(self, action: #selector(didClickSelectButton(_:)), for: .touchUpInside)
    }
    
    func _layoutViews() {
        imageView.frame = contentView.bounds
        selectButton.frame = CGRect(x: bounds.maxX - AssetCollectionViewCellConst.selectButtonWidth - AssetCollectionViewCellConst.selectButtonMargin,
                                    y: AssetCollectionViewCellConst.selectButtonMargin,
                                width: AssetCollectionViewCellConst.selectButtonWidth,
                               height: AssetCollectionViewCellConst.selectButtonHeight)
    }
}

// MARK: - Actions

extension TTAAssetCollectionViewCell {
    func didClickSelectButton(_ button: TTASelectButton) {
        button.selectState = button.selectState == .default ? .selected : .default
    }
}
