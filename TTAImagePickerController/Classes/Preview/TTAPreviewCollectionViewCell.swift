//
//  TTAPreviewCollectionViewCell.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTAPreviewCollectionViewCell: UICollectionViewCell {
    
    fileprivate let zoomView = TTAPreviewZoomView()
    
    override init(frame: CGRect) {
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
            backgroundColor = .clear
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        zoomView.frame = contentView.bounds
    }
    
    func configImage(with image: UIImage? = nil) {
        zoomView.config(image: image)
    }
}
