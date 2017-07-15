//
//  TTAPreviewToolBar.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

protocol TTAPreviewToolBarDelegate: class {
    func previewToolBar(toolBar: TTAPreviewToolBar, didClickDone button: UIButton)
}

class TTAPreviewToolBar: UIView {
    
    weak var delegate: TTAPreviewToolBarDelegate?
    
    var selectItemTintColor: UIColor? {
        didSet {
            countLabel.selectItemTintColor = selectItemTintColor
        }
    }
    
    fileprivate var doneButton = UIButton(type: .system)
    fileprivate let countLabel = TTASelectCountLabel()
    
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
            addSubview(doneButton)
            addSubview(countLabel)
        }
        
        func _configViews() {
            backgroundColor = UIColor.black.withAlphaComponent(0.5)
            doneButton.addTarget(self, action: #selector(didClickDoneButton), for: .touchUpInside)
            doneButton.setTitle("Done", for: .normal)
            doneButton.setTitleColor(.lightGray, for: .disabled)
            doneButton.contentHorizontalAlignment = .right
            doneButton.isEnabled = false
            countLabel.isHidden = true
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        let doneButtonWidth = self.width()
        let doneButtonX = bounds.width - rightMargin() - doneButtonWidth
        doneButton.frame = CGRect(x: doneButtonX, y: 0, width: doneButtonWidth, height: type(of: self).height())
        let countLabelWH: CGFloat = 26
        countLabel.frame = CGRect(x: doneButtonX - countLabelWH, y: (bounds.height - countLabelWH) / 2, width: countLabelWH, height: countLabelWH)
        
    }
    
    func width() -> CGFloat {
        guard let text = doneButton.titleLabel?.text else { return 0 }
        return (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: type(of: self).height()), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: doneButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 17)], context: nil).size.width + 3
    }
    
    static func height() -> CGFloat {
        return 44
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
}

// MARK: - Public Method

extension TTAPreviewToolBar {
    func update(count: Int) {
        countLabel.config(with: count)
        doneButton.isEnabled = count > 0
    }
}
