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
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDelete button: UIButton)
}

class TTAPreviewToolBar: UIView {
    
    weak var delegate: TTAPreviewToolBarDelegate?
    
    public var allowDeleteImage = false
    public var selectItemTintColor: UIColor? {
        didSet {
            countLabel.selectItemTintColor = selectItemTintColor
        }
    }
    
    fileprivate let doneButton = UIButton(type: .system)
    fileprivate let countLabel = TTASelectCountLabel()
    fileprivate let previewVideoButton = UIButton(type: .system)
    fileprivate let deleteButton = UIButton(type: .system)
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
        func createViews() {
            addSubview(bgView)
            bgView.contentView.addSubview(doneButton)
            bgView.contentView.addSubview(previewVideoButton)
            bgView.contentView.addSubview(countLabel)
            bgView.contentView.addSubview(deleteButton)
        }
        
        func configViews() {
            backgroundColor = .clear
            bgView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            doneButton.addTarget(self,
                                 action: #selector(didClickDoneButton),
                                 for: .touchUpInside)
            doneButton.setTitle(Bundle.localizedString(for: "Done"),
                                for: .normal)
            doneButton.setTitleColor(.lightGray,
                                     for: .disabled)
            doneButton.contentHorizontalAlignment = .right
            doneButton.isEnabled = false
            doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            previewVideoButton.addTarget(self,
                                         action: #selector(didClickVideoPreviewButton),
                                         for: .touchUpInside)
            previewVideoButton.setTitle(Bundle.localizedString(for: "Preview"),
                                        for: .normal)
            previewVideoButton.isHidden = true
            countLabel.isHidden = true
            countLabel.selectItemTintColor = doneButton.tintColor
            deleteButton.addTarget(self,
                                   action: #selector(didClickDeleteButton),
                                   for: .touchUpInside)
            deleteButton.setTitleColor(.lightGray,
                                       for: .disabled)
            deleteButton.setTitle(UIFont.IconFont.trashMark.rawValue,
                                  for: .normal)
            deleteButton.titleLabel?.font = UIFont.iconfont(size: UIFont.IconFontSize.trashMark)
        }
        
        createViews()
        configViews()
    }
    
    func layoutViews() {
        bgView.frame = bounds
        let doneButtonWidth = width(doneButton)
        let doneButtonX = bounds.width - rightMargin() - doneButtonWidth
        let countLabelWH: CGFloat = 26
        let deleteButtonW: CGFloat = allowDeleteImage ? 26 : 0
        let toolBarHeight: CGFloat = type(of: self).height(with: 0)
        doneButton.frame = CGRect(
            x: doneButtonX,
            y: 0,
            width: doneButtonWidth,
            height: toolBarHeight)
        countLabel.frame = CGRect(
            x: doneButtonX - countLabelWH,
            y: (toolBarHeight - countLabelWH) / 2,
            width: countLabelWH,
            height: countLabelWH)
        deleteButton.frame = CGRect(
            x: rightMargin(),
            y: 0,
            width: deleteButtonW,
            height: toolBarHeight)
        previewVideoButton.frame = CGRect(
            x: deleteButton.frame.maxX + (allowDeleteImage ? margin() : 0),
            y: 0,
            width: width(previewVideoButton),
            height: toolBarHeight)
    }
    
    func width(_ button: UIButton) -> CGFloat {
        guard let text = button.titleLabel?.text else { return 0 }
        return (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude,
                         height: type(of: self).height(with: 0)),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 17)],
            context: nil).size.width + 3
    }
    
    static func height(with addition: CGFloat) -> CGFloat {
        let orientation = UIApplication.shared.statusBarOrientation
        return (orientation.isLandscape ? 32 : (addition > 0 ? 49 : 44)) + addition
    }
    
    func rightMargin() -> CGFloat {
        return 16
    }
    
    func margin() -> CGFloat {
        return 5
    }
}

// MARK: - Actions

extension TTAPreviewToolBar {
    @objc func didClickDoneButton() {
        delegate?.previewToolBar(toolBar: self, didClickDone: doneButton)
    }
    
    @objc func didClickVideoPreviewButton() {
        delegate?.previewToolBar(toolBar: self, didClickVideoPreview: previewVideoButton)
    }
    
    @objc func didClickDeleteButton() {
        delegate?.previewToolBar(toolBar: self, didClickDelete: deleteButton)
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
