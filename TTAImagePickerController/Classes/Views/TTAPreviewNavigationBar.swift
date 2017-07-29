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
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
//            if #available(iOS 11.0, *) {
//                backButton.contentHorizontalAlignment = .leading
//            } else {
                backButton.contentHorizontalAlignment = .left
//            }
            
            selectButton.addTarget(self, action: #selector(didClickSelectButton(_:)), for: .touchUpInside)
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        bgView.frame = bounds
        backButton.frame = CGRect(x: 0, y: 20, width: 100, height: bounds.height - 20)
        selectButton.frame = CGRect(x: bounds.width - 26 - 10, y: (bounds.height - 20 - 26) / 2 + 20, width: 26, height: 26)
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
    
    func orientationDidChanged(notify: Notification) {
        setNeedsLayout()
    }
}

// MARK: - Const

extension TTAPreviewNavigationBar {
    static func height() -> CGFloat {
        let orientation = UIDevice.current.orientation
        return (orientation == .landscapeLeft || orientation == .landscapeRight) ? 52 : 64
    }
}
