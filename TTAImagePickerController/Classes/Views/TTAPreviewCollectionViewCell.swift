//
//  TTAPreviewCollectionViewCell.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import Photos

protocol TTAPreviewContentViewDelegate: class {
    func tappedPreviewContentView(_ contentView: TTAPreviewContentViewCompatiable)
}

protocol TTAPreviewContentViewCompatiable {}

protocol TTAPreviewCollectionViewCellDelegate: class {
    func tappedPreviewCell(_ cell: TTAPreviewCollectionViewCell)
}

class TTAPreviewCollectionViewCell: UICollectionViewCell {
    
    fileprivate(set) weak var delegate: TTAPreviewCollectionViewCellDelegate?
    fileprivate(set) var isToolBarHidden = false
    
    fileprivate let zoomView = TTAPreviewZoomView()
    fileprivate let videoView = TTAPreviewVideoView()
    fileprivate let progressView = TTAProgressView()
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateProgress(0, error: nil)
    }
}

// MARK: - UI

fileprivate extension TTAPreviewCollectionViewCell {
    func setupUI() {
        func createViews() {
            contentView.addSubview(videoView)
            contentView.addSubview(zoomView)
            contentView.addSubview(progressView)
        }
        
        func configViews() {
            backgroundColor = .white
            videoView.tapDelegate = self
            videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            zoomView.tapDelegate = self
            zoomView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressView.isHidden = true
        }
        
        createViews()
        configViews()
        layoutViews()
    }
    
    func layoutViews() {
        videoView.frame = CGRect(x: 0, y: 0, width: bounds.width - TTAPreviewCollectionViewCell.cellMargin(), height: bounds.height)
        zoomView.frame = videoView.frame
        progressView.frame = CGRect(x: zoomView.bounds.width - TTAProgressView.rightMargin() - TTAProgressView.widthAndHeight(), y: zoomView.progressViewY(isToolBarHidden: isToolBarHidden), width: TTAProgressView.widthAndHeight(), height: TTAProgressView.widthAndHeight())
    }
}

extension TTAPreviewCollectionViewCell {
    
    func configCell(tag: Int, delegate: TTAPreviewCollectionViewCellDelegate?, isHiddenBars: Bool, image: UIImage? = nil) {
        self.tag = tag;
        self.delegate = delegate;
        configImage(with: image)
        configCell(isHiddenBars: isHiddenBars)
    }
    
    func configImage(with image: UIImage?) {
        zoomView.config(image: image)
        videoView.isHidden = true
        zoomView.isHidden = false
        progressView.isHidden = true
    }
    
    func configVideo(with playerItem: AVPlayerItem?) {
        videoView.update(with: playerItem)
        videoView.isHidden = false
        zoomView.isHidden = true
        progressView.isHidden = true
    }
    
    func configCell(isHiddenBars: Bool) {
        backgroundColor = isHiddenBars ? .black : .white
        isToolBarHidden = isHiddenBars
        updateProgressFrame()
    }
    
    func updateProgressFrame() {
        let y = zoomView.progressViewY(isToolBarHidden: isToolBarHidden)
        guard y > 0 else { return }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        UIView.setAnimationCurve(.easeInOut)
        progressView.frame.origin.y = y
        UIView.commitAnimations()
    }
    
    func updateProgress(_ progress: Double, error: Error?) {
        if let error = error {
            progressView.progressError(error)
            return
        }
        let shouldUpdate = (progress >= 0 && progress < 1)
        progressView.isHidden = !shouldUpdate
        guard shouldUpdate else { return }
        progressView.update(to: progress)
        updateProgressFrame()
    }
    
    func orientationDidChanged() {
        zoomView.orientationDidChanged()
    }
}

// MARK: - Const

extension TTAPreviewCollectionViewCell {
    static func cellMargin() -> CGFloat {
        return 30
    }
}

// MARK: - TTAPreviewZoomViewDelegate

extension TTAPreviewCollectionViewCell: TTAPreviewContentViewDelegate {
    func tappedPreviewContentView(_ contentView: TTAPreviewContentViewCompatiable) {
        delegate?.tappedPreviewCell(self)
    }
}
