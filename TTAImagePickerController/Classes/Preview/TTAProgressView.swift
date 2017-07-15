//
//  TTAProgressView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 09/07/2017.
//

import UIKit

class TTAProgressView: UIView {
    fileprivate let circleLayer = CAShapeLayer()
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate var progress: Double = 0.02
    
    override var isHidden: Bool {
        didSet {
            progress = 0.02
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareCircleLayer()
        prepareProgressLayer()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        let radius = rect.size.width / 2
        
        circleLayer.frame = bounds
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.removeFromSuperlayer()
        layer.addSublayer(circleLayer)
        
        let startA = -Double.pi / 2
        let endA = startA + Double.pi * 2 * progress
        progressLayer.frame = bounds
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startA), endAngle: CGFloat(endA), clockwise: true)
        path.addLine(to: center)
        path.addLine(to: CGPoint(x: rect.width / 2, y: 0))
        progressLayer.path = path.cgPath
        progressLayer.removeFromSuperlayer()
        layer.addSublayer(progressLayer)
    }
    func prepareCircleLayer() {
        circleLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.opacity = 1
        circleLayer.lineWidth = 2
        
        circleLayer.shadowColor = UIColor.black.cgColor
        circleLayer.shadowOffset = CGSize(width: 1, height: 1)
        circleLayer.shadowOpacity = 0.5
        circleLayer.shadowRadius = 2
    }
    
    func prepareProgressLayer() {
        progressLayer.fillColor = UIColor.white.cgColor
        progressLayer.opacity = 1
    }
    
    func update(to progress: Double) {
        guard progress > 0.02 else { return }
        self.progress = progress
        setNeedsDisplay()
    }
    
    func progressError(_ error: Error) {
        isHidden = false
        progress = 0
        let errorImage = UIImage.image(with: .warningMark, in: bounds.size, tintColor: .red, cornerRadius: bounds.width / 2)
        progressLayer.contents = errorImage.cgImage
    }
}

extension TTAProgressView {
    static func rightMargin() -> CGFloat {
        return 16
    }
    static func bottomMargin() -> CGFloat {
        return 16
    }
    static func widthAndHeight() -> CGFloat {
        return 20
    }
}
