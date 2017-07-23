//
//  TTAPreviewZoomView.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

protocol TTAPreviewZoomViewDelegate: class {
    func tappedPreviewZoomView(_ zoomView: TTAPreviewZoomView)
}

class TTAPreviewZoomView: UIScrollView {
    
    weak var tapDelegate: TTAPreviewZoomViewDelegate?
    
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
    }
}

// MARK: - Public Method

extension TTAPreviewZoomView {
    
    /// Config the imageView's `image`
    func config(image: UIImage?) {
        imageView.image = image
        refreshFrame()
    }
    
    func progressViewY(isToolBarHidden: Bool) -> CGFloat {
        if imageView.image == nil {
            return bounds.height - TTAProgressView.bottomMargin() - TTAProgressView.widthAndHeight() - (isToolBarHidden ? 0 : TTAPreviewToolBar.height())
        }
        let y: CGFloat
        if imageView.frame.maxY < bounds.maxY - (isToolBarHidden ? 0 : TTAPreviewToolBar.height()) {
            y = imageView.frame.maxY - TTAProgressView.bottomMargin() - TTAProgressView.widthAndHeight()
        } else {
            y = bounds.height - TTAProgressView.bottomMargin() - TTAProgressView.widthAndHeight() - (isToolBarHidden ? 0 : TTAPreviewToolBar.height())
        }
        return y
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
            maximumZoomScale = 2.5
            bounces = false
            showsVerticalScrollIndicator = false
            showsHorizontalScrollIndicator = false
            backgroundColor = .clear
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
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
    }
    
    func refreshFrame() {
        guard let image = imageView.image else { return }
        let newHeight: CGFloat
        let newWidth: CGFloat
        if bounds.height > bounds.width {
            newWidth = bounds.width
            newHeight = newWidth * image.size.height / image.size.width
        } else {
            newHeight = bounds.height
            newWidth = newHeight * image.size.width / image.size.height
        }
        let size = CGSize(width: newWidth, height: newHeight)
        contentSize = size
        imageView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        refreshImageViewCenter()
    }
    
    func refreshImageViewCenter() {
        let offsetX = bounds.width > contentSize.width ? (bounds.width - contentSize.width) * 0.5 : 0
        let offsetY = bounds.height > contentSize.height ? (bounds.height - contentSize.height) * 0.5 : 0
        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX, y: contentSize.height * 0.5 + offsetY)
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
        tapDelegate?.tappedPreviewZoomView(self)
    }
    
    func doubleTapGestureAction(doubleTap: UITapGestureRecognizer) {
        guard doubleTap.state == .ended else { return }
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.25)
        if zoomScale != 1 {
            setZoomScale(1, animated: true)
        } else {
            let touchPoint = doubleTap.location(in: imageView)
            let width = bounds.width / maximumZoomScale
            let height = bounds.height / maximumZoomScale
            let zoomToRect = CGRect(x: touchPoint.x - width / 2, y: touchPoint.y - height / 2, width: width, height: height)
            zoom(to: zoomToRect, animated: true)
        }
        tapDelegate?.tappedPreviewZoomView(self)
    }
    
    func orientationDidChanged() {
        refreshFrame()
        setZoomScale(1, animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension TTAPreviewZoomView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageViewCenter()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        refreshImageViewCenter()
    }
}