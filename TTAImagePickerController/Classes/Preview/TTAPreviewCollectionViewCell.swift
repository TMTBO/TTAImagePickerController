//
//  TTAPreviewCollectionViewCell.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTAPreviewCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI

extension TTAPreviewCollectionViewCell {
    func setupUI() {
        func _createViews() {
            
        }
        
        func _configViews() {
            backgroundColor = .white
        }
        
        func _layoutViews() {
            
        }
        
        _createViews()
        _configViews()
        _layoutViews()
    }
    
}
