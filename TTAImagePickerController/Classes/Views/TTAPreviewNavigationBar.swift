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

    fileprivate let backButton = UIButton(type: .system)
    fileprivate let selectButton = TTASelectButton()
    fileprivate let timeLabel = UILabel()
    fileprivate let bgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
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
            addSubview(bgView)
            bgView.contentView.addSubview(backButton)
            bgView.contentView.addSubview(selectButton)
            bgView.contentView.addSubview(timeLabel)
        }
        
        func _configViews() {
            backgroundColor = UIColor.clear
            bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            timeLabel.textColor = .white
            timeLabel.font = UIFont.systemFont(ofSize: 16)
            timeLabel.adjustsFontSizeToFitWidth = true
            timeLabel.textAlignment = .center
            timeLabel.numberOfLines = 2
            backButton.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
            backButton.setTitle(UIFont.IconFont.backMark.rawValue, for: .normal)
            backButton.titleLabel?.font = UIFont.iconfont(size: UIFont.IconFontSize.backMark)
            backButton.setTitleColor(selectItemTintColor, for: .normal)
            
            selectButton.addTarget(self, action: #selector(didClickSelectButton(_:)), for: .touchUpInside)
        }
        
        _createViews()
        _configViews()
    }
    
    func layoutViews() {
        var layoutY: CGFloat = 20
        var layoutHeight: CGFloat = bounds.height
        var layoutMaxX: CGFloat = bounds.width
        
        if #available(iOS 11.0, *) {
            let rect = safeAreaLayoutGuide.layoutFrame
            layoutY = rect.minY
            layoutHeight = rect.height
            layoutMaxX = rect.maxX
            if UIApplication.shared.isStatusBarHidden && UIApplication.shared.statusBarOrientation.isLandscape { // Adjust iPhoneX hidden status bar when Landscape
                backButton.contentHorizontalAlignment = .trailing
                backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
            } else {
                backButton.contentHorizontalAlignment = .leading
                backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            }
        } else {
            backButton.contentHorizontalAlignment = .left
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        }
        
        bgView.frame = bounds
        backButton.frame = CGRect(x: 0, y: layoutY, width: 100, height: layoutHeight)
        selectButton.frame = CGRect(x: layoutMaxX - 26 - 10, y: layoutY + (layoutHeight - 26) / 2, width: 26, height: 26)
        timeLabel.frame = CGRect(x: backButton.frame.maxX + 10, y: backButton.frame.minY, width: bounds.width - 2 * (backButton.frame.width + 10), height: backButton.frame.height)
    }
    
    func updateImageInfo(with creationDate: Date?) {
        guard let creationDate = creationDate else { return }
        if !hasConfigedDateFormatter {
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .medium
            hasConfigedDateFormatter = true
        }
        timeLabel.text = dateFormatter.string(from: creationDate)
    }
    
    func configNavigationBar(isSelected: Bool) {
        guard selectButton.isSelected != isSelected else { return }
        selectButton.selectState = isSelected ? .selected : .default
    }
    
    func configHideSelectButton(_ isHidden: Bool) {
        selectButton.isHidden = isHidden
    }
}

// MARK: - Actions

extension TTAPreviewNavigationBar {
    @objc func didClickBackButton(_ button: UIButton) {
        delegate?.previewNavigationBar(self, didClickBack: button)
    }
    
    @objc func didClickSelectButton(_ button: TTASelectButton) {
        guard let (canOperate, asset) = delegate?.canOperate(),
            canOperate == true,
            let operateAsset = asset else { return }
        selectButton.selectState = selectButton.selectState == .selected ? .default : .selected
        delegate?.previewNavigationBar(self, asset: operateAsset, isSelected: selectButton.isSelected)
    }
}

// MARK: - Const

extension TTAPreviewNavigationBar {
    static func height(with addition: CGFloat) -> CGFloat {
        let orientation = UIApplication.shared.statusBarOrientation
        if UIApplication.shared.isStatusBarHidden { // Adjust iPhoneX hidden status bar when Landscape
            return orientation.isLandscape ? 32 : (44 + addition)
        } else {
            return orientation.isLandscape ? 52 : (44 + addition)
        }
    }
}
