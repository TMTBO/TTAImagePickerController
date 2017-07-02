//
//  TTAPreviewZoomView.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTAPreviewZoomView: UIScrollView {
    
    fileprivate let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
}

// MARK: - Public Method

extension TTAPreviewZoomView {
    
    /// Config the imageView's `image`
    func config(image: UIImage?) {
        imageView.image = image
    }
}

// MARK: - UI

fileprivate extension TTAPreviewZoomView {
    func setupUI() {
        func _addViews() {
            addSubview(imageView)
        }
        
        func _configViews() {
            
            delegate = self
            minimumZoomScale = 0.5
            maximumZoomScale = 2
            showsVerticalScrollIndicator = false
            showsHorizontalScrollIndicator = false
            backgroundColor = .clear
            
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(tap:)))
            addGestureRecognizer(tap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureAction(doubleTap:)))
            doubleTap.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap)
            
            tap.require(toFail: doubleTap)
        }
        
        _addViews()
        _configViews()
        layoutViews()
    }
    
    func layoutViews() {
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width - 30, height: bounds.height)
    }
}

// MARK: - Const

fileprivate extension TTAPreviewZoomView {
    static func animationTimeInterval() -> TimeInterval {
        return 0.25
    }
}

// MARK: - Actions

extension TTAPreviewZoomView {
    
    func tapGestureAction(tap: UITapGestureRecognizer) {
        
    }
    
    func doubleTapGestureAction(doubleTap: UITapGestureRecognizer) {
        guard doubleTap.state == .ended else { return }
        if zoomScale > 1 {
            setZoomScale(1, animated: true)
        } else {
            let touchPoint = doubleTap.location(in: imageView)
            let width = bounds.width / maximumZoomScale
            let height = bounds.height / maximumZoomScale
            let zoomToRect = CGRect(x: touchPoint.x - width / 2, y: touchPoint.y - height / 2, width: width, height: height)
            zoom(to: zoomToRect, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension TTAPreviewZoomView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = bounds.width > contentSize.width ? (bounds.width - contentSize.width) * 0.5 : 0
        let offsetY = bounds.height > contentSize.height ? (bounds.height - contentSize.height) * 0.5 : 0
        let lineSpace: CGFloat = 30
        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX - lineSpace / 2, y: contentSize.height * 0.5 + offsetY)
    }
}
