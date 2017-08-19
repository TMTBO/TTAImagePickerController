//
//  TTACameraCell.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 18/08/2017.
//

import UIKit

class TTACameraCell: UICollectionViewCell {
    
    fileprivate let cameraLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cameraLabel.frame = contentView.bounds
    }
}

extension TTACameraCell {
    func setupUI() {
        cameraLabel.font = UIFont.iconfont(size: UIFont.IconFontSize.cameraMark)
        cameraLabel.text = UIFont.IconFont.cameraMark.rawValue
        cameraLabel.textColor = .gray
        cameraLabel.textAlignment = .center
        cameraLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        contentView.addSubview(cameraLabel)
    }
}
