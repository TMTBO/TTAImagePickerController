//
//  TTAPreviewCollectionViewCell.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

protocol TTAPreviewCollectionViewCellDelegate: class {
    func tappedPreviewCell(_ cell: TTAPreviewCollectionViewCell)
}

class TTAPreviewCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TTAPreviewCollectionViewCellDelegate?
    
    fileprivate var zoomView: TTAPreviewZoomView
    
    override init(frame: CGRect) {
        zoomView =  TTAPreviewZoomView(frame: frame)
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle

extension TTAPreviewCollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

extension TTAPreviewCollectionViewCell {
    func setupUI() {
        func _createViews() {
            contentView.addSubview(zoomView)
        }
        
        func _configViews() {
            backgroundColor = .white
            zoomView.tapDelegate = self
            zoomView.frame = CGRect(x: 0, y: 0, width: bounds.width - 30, height: bounds.height)
            zoomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
    }
    
    func configImage(with image: UIImage? = nil) {
        zoomView.config(image: image)
    }
    
    func configBackgroundColor(isChange: Bool) {
        guard isChange else { return }
        if backgroundColor == .white {
            backgroundColor = .black
        } else {
            backgroundColor = .white
        }
    }
}

extension TTAPreviewCollectionViewCell: TTAPreviewZoomViewDelegate {
    func tappedPreviewZoomView(_ zoomView: TTAPreviewZoomView) {
        delegate?.tappedPreviewCell(self)
    }
}
