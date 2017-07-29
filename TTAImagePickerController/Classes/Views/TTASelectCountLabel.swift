//
//  TTASelectCountLabel.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTASelectCountLabel: UILabel {
    
    var selectItemTintColor: UIColor? {
        didSet {
            backgroundColor = selectItemTintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        corner(with: bounds.height / 2)
    }
}

extension TTASelectCountLabel {
    func setupUI() {
        backgroundColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
        textColor = .white
        textAlignment = .center
        adjustsFontSizeToFitWidth = true
    }
    
    func config(with count: Int) {
        if count <= 0 {
            isHidden = true
            return
        }
        text = "\(count)"
        isHidden = false
        selectItemSpringAnimation()
    }
}
