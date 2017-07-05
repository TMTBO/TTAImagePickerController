//
//  TTAPreviewNavigationBar.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

protocol TTAPreviewNavigationBarDelegate: class {
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, didClickBack button: UIButton)
    func canOperate() -> (canOperate: Bool, asset: PHAsset?)
    func previewNavigationBar(_ navigationBar: TTAPreviewNavigationBar, asset: PHAsset, isSelected: Bool)
}

class TTAPreviewNavigationBar: UIView {
    
    weak var delegate: TTAPreviewNavigationBarDelegate?
    
    var selectItemTintColor: UIColor? {
        didSet {
            selectButton.selectItemTintColor = selectItemTintColor
        }
    }

    fileprivate var backButton = UIButton()
    fileprivate var selectButton = TTASelectButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

extension TTAPreviewNavigationBar {
    func setupUI() {
        func _createViews() {
            addSubview(backButton)
            addSubview(selectButton)
        }
        
        func _configViews() {
            backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            backButton.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
            backButton.setTitle(UIFont.IconFont.backMark.rawValue, for: .normal)
            backButton.titleLabel?.font = UIFont.iconfont(size: UIFont.IconFontSize.backMark)
            backButton.setTitleColor(selectItemTintColor, for: .normal)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            if #available(iOS 11.0, *) {
                backButton.contentHorizontalAlignment = .leading
            } else {
                backButton.contentHorizontalAlignment = .left
            }
                
            selectButton.addTarget(self, action: #selector(didClickSelectButton(_:)), for: .touchUpInside)
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        backButton.frame = CGRect(x: 0, y: 0, width: 100, height: 64)
        selectButton.frame = CGRect(x: bounds.width - 26 - 10, y: (64 - 26) / 2, width: 26, height: 26)
    }
    
    func configNavigationBar(isSelected: Bool) {
        guard selectButton.isSelected != isSelected else { return }
        selectButton.selectState = isSelected ? .selected : .default
    }
}

// MARK: - Actions

extension TTAPreviewNavigationBar {
    func didClickBackButton(_ button: UIButton) {
        delegate?.previewNavigationBar(self, didClickBack: button)
    }
    
    func didClickSelectButton(_ button: TTASelectButton) {
        guard let (canOperate, asset) = delegate?.canOperate(),
            canOperate == true,
            let operateAsset = asset else { return }
        selectButton.selectState = selectButton.selectState == .selected ? .default : .selected
        delegate?.previewNavigationBar(self, asset: operateAsset, isSelected: selectButton.isSelected)
    }
}
