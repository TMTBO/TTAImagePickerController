//
//  TTAAssetCollectionViewCell.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 17/06/2017.
//

import Photos

protocol TTAAssetCollectionViewCellDelegate: class {
    func canOperateCell(cell: TTAAssetCollectionViewCell) -> Bool
    func assetCell(_ cell: TTAAssetCollectionViewCell, isSelected: Bool)
}

class TTAAssetCollectionViewCell: UICollectionViewCell {
    
    struct AssetCollectionViewCellConst {
        let selectButtonMargin: CGFloat = 3
        let selectButtonHeight: CGFloat = 26
        let selectButtonWidth: CGFloat = 26
    }
    
    weak var delegate: TTAAssetCollectionViewCellDelegate?
    
    /// The tint color which item was selected, default is `UIColor(colorLiteralRed: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)`
    public var selectItemTintColor: UIColor? {
        didSet {
            selectButton.selectItemTintColor = selectItemTintColor
        }
    }
    
    fileprivate let imageView = UIImageView()
    fileprivate let selectButton = TTASelectButton()
    
    fileprivate let const = AssetCollectionViewCellConst()
    
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

fileprivate extension TTAAssetCollectionViewCell {
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
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        selectButton.selectItemTintColor = selectItemTintColor
        selectButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        selectButton.addTarget(self, action: #selector(didClickSelectButton(_:)), for: .touchUpInside)
    }
    
    func _layoutViews() {
        imageView.frame = contentView.bounds
        selectButton.frame = CGRect(x: bounds.maxX - const.selectButtonWidth - const.selectButtonMargin,
                                    y: const.selectButtonMargin,
                                width: const.selectButtonWidth,
                               height: const.selectButtonHeight)
    }
}

// MARK: - Data

extension TTAAssetCollectionViewCell {
    
    func configState(isSelected: Bool) {
        selectButton.selectState = isSelected ? .selected : .default
    }
    
    func configImage(with image: UIImage? = nil) {
        imageView.image = image
    }
}

// MARK: - Actions

extension TTAAssetCollectionViewCell {
    func didClickSelectButton(_ button: TTASelectButton) {
        guard let canOperate = delegate?.canOperateCell(cell: self), canOperate == true else { return }
        button.selectState = button.selectState == .selected ? .default : .selected
        delegate?.assetCell(self, isSelected: button.selectState == .selected ? true : false)
    }
}
