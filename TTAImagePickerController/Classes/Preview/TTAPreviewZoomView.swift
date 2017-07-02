//
//  TTAPreviewZoomView.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTAPreviewZoomView: UIScrollView {
    
    fileprivate let imageView = UIImageView()
    fileprivate var imageViewFromFrame: CGRect!
    fileprivate var imageViewToFrame: CGRect!
    fileprivate var imageURLString: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
}

// MARK: - Public Method

extension TTAPreviewZoomView {
    
    /// Config the imageView's `image` and if it's the firstOpen then animation from `fromFram` to `toFrame`
    public func config(from fromFrame: CGRect, to toFrame: CGRect, image: UIImage?, imageURLString: String?, isFirstOpen: Bool) {
        zoomScale = 1
        
        imageView.image = image
        imageView.frame = fromFrame
        self.imageURLString = imageURLString
        
        imageViewFromFrame = fromFrame
        imageViewToFrame = toFrame
        guard isFirstOpen else {
            imageView.frame = toFrame
            return
        }
        UIView.animate(withDuration: TTAPreviewZoomView.animationTimeInterval()) { [weak self] in
            guard let `self` = self else { return }
            self.imageView.frame = toFrame
        }
    }
    
    /// Config the imageView's `image`
    public func config(image: UIImage?) {
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
            backgroundColor = UIColor(white: 0, alpha: 0.9)
            
            imageView.alpha = 1.0
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(tap:)))
            addGestureRecognizer(tap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureAction(doubleTap:)))
            doubleTap.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTap)
            
            tap.require(toFail: doubleTap)
        }
        func _layoutViews() {
            imageView.frame = bounds
        }
        _addViews()
        _configViews()
        _layoutViews()
    }
}

// MARK: - Const

fileprivate extension TTAPreviewZoomView {
    static func animationTimeInterval() -> TimeInterval {
        return 0.25
    }
}

// MARK: - Actions

fileprivate extension TTAPreviewZoomView {
    
    @objc func tapGestureAction(tap: UITapGestureRecognizer) {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        UIView.animate(withDuration: TTAPreviewZoomView.animationTimeInterval(), animations: { [weak self] in
            guard let `self` = self else { return }
            let frame = self.convert(self.imageViewFromFrame, from: UIApplication.shared.keyWindow)
            self.imageView.frame = frame
        }) { (isFinished) in
            let topController = UIApplication.shared.keyWindow?.rootViewController
            topController?.dismiss(animated: true, completion: nil)
        }
    }
    @objc func doubleTapGestureAction(doubleTap: UITapGestureRecognizer) {
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
