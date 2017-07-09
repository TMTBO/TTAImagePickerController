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
    fileprivate var progressView = TTAProgressView()
    
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

fileprivate extension TTAPreviewCollectionViewCell {
    func setupUI() {
        func _createViews() {
            contentView.addSubview(zoomView)
            contentView.addSubview(progressView)
        }
        
        func _configViews() {
            backgroundColor = .white
            zoomView.tapDelegate = self
            zoomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressView.isHidden = true
        }
        
        _createViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        zoomView.frame = CGRect(x: 0, y: 0, width: bounds.width - TTAPreviewCollectionViewCell.cellMargin(), height: bounds.height)
        progressView.frame = CGRect(x: zoomView.bounds.width - TTAProgressView.rightMargin() - TTAProgressView.widthAndHeight(), y: zoomView.bounds.height - TTAProgressView.bottomMargin() - TTAProgressView.widthAndHeight(), width: TTAProgressView.widthAndHeight(), height: TTAProgressView.widthAndHeight())
    }
}

extension TTAPreviewCollectionViewCell {
    func configImage(with image: UIImage? = nil) {
        zoomView.config(image: image)
        progressView.isHidden = true
    }
    
    func configBackgroundColor(isChange: Bool) {
        guard isChange else { return }
        if backgroundColor == .white {
            backgroundColor = .black
        } else {
            backgroundColor = .white
        }
    }
    
    func updateProgress(_ progress: Double) {
        let shouldUpdate = (progress >= 0 && progress <= 1)
        progressView.isHidden = !shouldUpdate
        guard shouldUpdate else { return }
        progressView.update(to: progress)
    }
}

// MARK: - Const

extension TTAPreviewCollectionViewCell {
    static func cellMargin() -> CGFloat {
        return 30
    }
}

// MARK: - TTAPreviewZoomViewDelegate

extension TTAPreviewCollectionViewCell: TTAPreviewZoomViewDelegate {
    func tappedPreviewZoomView(_ zoomView: TTAPreviewZoomView) {
        delegate?.tappedPreviewCell(self)
    }
}
