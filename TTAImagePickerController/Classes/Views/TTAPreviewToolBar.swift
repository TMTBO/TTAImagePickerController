//
//  TTAPreviewToolBar.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

protocol TTAPreviewToolBarDelegate: class {
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDone button: UIButton)
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickVideoPreview button: UIButton)
}

class TTAPreviewToolBar: UIView {
    
    weak var delegate: TTAPreviewToolBarDelegate?
    
    var selectItemTintColor: UIColor? {
        didSet {
            countLabel.selectItemTintColor = selectItemTintColor
        }
    }
    
    fileprivate let doneButton = UIButton(type: .system)
    fileprivate let countLabel = TTASelectCountLabel()
    fileprivate let previewVideoButton = UIButton(type: .system)
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

extension TTAPreviewToolBar {
    func setupUI() {
        func _createViews() {
            addSubview(bgView)
            bgView.contentView.addSubview(doneButton)
            bgView.contentView.addSubview(previewVideoButton)
            bgView.contentView.addSubview(countLabel)
        }
        
        func _configViews() {
            backgroundColor = .clear
            bgView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            doneButton.addTarget(self, action: #selector(didClickDoneButton), for: .touchUpInside)
            doneButton.setTitle(Bundle.localizedString(for: "Done"), for: .normal)
            doneButton.setTitleColor(.lightGray, for: .disabled)
            doneButton.contentHorizontalAlignment = .right
            doneButton.isEnabled = false
            previewVideoButton.addTarget(self, action: #selector(didClickVideoPreviewButton), for: .touchUpInside)
            previewVideoButton.setTitle(Bundle.localizedString(for: "Preview"), for: .normal)
            previewVideoButton.isHidden = true
            countLabel.isHidden = true
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        bgView.frame = bounds
        let doneButtonWidth = width(doneButton)
        let doneButtonX = bounds.width - rightMargin() - doneButtonWidth
        let countLabelWH: CGFloat = 26
        doneButton.frame = CGRect(x: doneButtonX, y: 0, width: doneButtonWidth, height: type(of: self).height())
        countLabel.frame = CGRect(x: doneButtonX - countLabelWH, y: (bounds.height - countLabelWH) / 2, width: countLabelWH, height: countLabelWH)
        previewVideoButton.frame = CGRect(x: rightMargin(), y: 0, width: width(previewVideoButton), height: type(of: self).height())
    }
    
    func width(_ button: UIButton) -> CGFloat {
        guard let text = button.titleLabel?.text else { return 0 }
        return (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                            height: type(of: self).height()),
                                               options: .usesLineFragmentOrigin,
                                               attributes: [NSFontAttributeName: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 17)],
                                               context: nil).size.width + 3
    }
    
    static func height() -> CGFloat {
        let orientation = UIApplication.shared.statusBarOrientation
        return orientation.isLandscape ? 32 : 44
    }
    
    func rightMargin() -> CGFloat {
        return 16
    }
}

// MARK: - Actions

extension TTAPreviewToolBar {
    func didClickDoneButton() {
        delegate?.previewToolBar(toolBar: self, didClickDone: doneButton)
    }
    
    func didClickVideoPreviewButton() {
        delegate?.previewToolBar(toolBar: self, didClickVideoPreview: previewVideoButton)
    }
}

// MARK: - Public Method

extension TTAPreviewToolBar {
    func update(count: Int, with enableDone: Bool) {
        guard !enableDone else {
            doneButton.isEnabled = enableDone
            countLabel.isHidden = enableDone
            return
        }
        countLabel.config(with: count)
        doneButton.isEnabled = count > 0
    }
    
    func showVideoPreviewOrNot(_ isShow: Bool) {
        previewVideoButton.isHidden = !isShow
    }
}
