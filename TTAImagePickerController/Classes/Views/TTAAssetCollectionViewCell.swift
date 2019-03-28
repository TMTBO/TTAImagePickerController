//
//  TTAAssetCollectionViewCell.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 17/06/2017.
//

import Photos

protocol TTAAssetCollectionViewCellDelegate: class {
    func canOperateCell(cell: TTAAssetCollectionViewCell) -> (canOperate: Bool, asset: PHAsset?)
    func assetCell(_ cell: TTAAssetCollectionViewCell, asset: PHAsset, isSelected: Bool)
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
    fileprivate let videoComponentView = TTAAssetComponentView()
    fileprivate let lightUpLayer = CALayer()
    
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
        contentView.addSubview(videoComponentView)
        layer.addSublayer(lightUpLayer)
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
        
        lightUpLayer.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1).cgColor
        lightUpLayer.opacity = 0
    }
    
    func _layoutViews() {
        imageView.frame = contentView.bounds
        selectButton.frame = CGRect(x: bounds.maxX - const.selectButtonWidth - const.selectButtonMargin,
                                    y: const.selectButtonMargin,
                                width: const.selectButtonWidth,
                               height: const.selectButtonHeight)
        videoComponentView.frame = CGRect(x: 0, y: bounds.height - TTAAssetComponentView.height(), width: bounds.width, height: TTAAssetComponentView.height())
        lightUpLayer.frame = contentView.bounds
    }
}

// MARK: - Data

extension TTAAssetCollectionViewCell {
    
    func configCell(with config: TTAAssetConfig) {
        self.tag = config.tag;
        self.delegate = config.delegate;
        configState(isSelected: config.isSelected)
        configImage(with: nil)
        configComponentView(with: config)
        guard config.canSelect else {
            selectButton.isHidden = !config.canSelect
            return
        }
        self.selectItemTintColor = config.selectItemTintColor
    }
    
    func configState(isSelected: Bool) {
        guard selectButton.isSelected != isSelected else { return }
        selectButton.selectState = isSelected ? .selected : .default
    }
    
    func configImage(with image: UIImage?) {
        imageView.image = image
    }
    
    func configComponentView(with config: TTAAssetConfig) {
        if config.isVideo {
            videoComponentView.isHidden = false
            videoComponentView.update(with: config.videoInfo)
        } else if config.isGif {
            videoComponentView.isHidden = false
            videoComponentView.update(isGif: true)
        } else {
            videoComponentView.isHidden = true
        }
    }
    
    func lightUp() {
        // MARK: - Animations
        func _lightupAnimation() -> CABasicAnimation {
            let animation = CABasicAnimation()
            animation.keyPath = "opacity"
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.9
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.isRemovedOnCompletion = true
            return animation
        }
        lightUpLayer.add(_lightupAnimation(), forKey: nil)
    }
}
// MARK: - Actions

extension TTAAssetCollectionViewCell {
    @objc func didClickSelectButton(_ button: TTASelectButton) {
        guard let (canOperate, asset) = delegate?.canOperateCell(cell: self),
            canOperate == true, let operateAsset = asset else { return }
        button.selectState = button.selectState == .selected ? .default : .selected
        delegate?.assetCell(self, asset: operateAsset, isSelected: button.isSelected)
    }
}
