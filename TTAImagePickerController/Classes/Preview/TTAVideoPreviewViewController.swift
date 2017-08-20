//
//  TTAVideoPreviewViewController.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 05/08/2017.
//

import Photos

class TTAVideoPreviewViewController: UIViewController {
    
    fileprivate let videoView = TTAPreviewVideoView()
    fileprivate var asset: PHAsset?
    
    convenience init(asset: PHAsset) {
        self.init(nibName: nil, bundle: nil)
        self.asset = asset
    }
    
    deinit {
        #if DEBUG
            print("TTAImagePickerController >>>>>> Video preview controller deinit")
        #endif
    }
}

// MARK: - Life Cycle

extension TTAVideoPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

extension TTAVideoPreviewViewController {
    func setupUI() {
        func createViews() {
            view.addSubview(videoView)
        }
        
        func configViews() {
            view.backgroundColor = .black
            videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            TTAImagePickerManager.fetchPreview(for: asset, progressHandler: { (progress, error, stop, info) in
                
            }) { (fetchResult) in
                if fetchResult.hasImage {
                    self.videoView.layer.contents = fetchResult.image?.cgImage
                    self.videoView.contentMode = .scaleAspectFit
                } else if fetchResult.hasPlayerItem {
                    self.videoView.update(with: fetchResult.playerItem)
                }
            }
        }
        
        createViews()
        configViews()
        layoutViews()
    }
    
    func layoutViews() {
        videoView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
}

// MARK: - TTAPreviewContentViewDelegate

extension TTAPreviewCollectionViewCell: TTAPreviewContentViewDelegate {
    func tappedPreviewContentView(_ contentView: TTAPreviewContentViewCompatiable) {
        delegate?.tappedPreviewCell(self)
    }
}
