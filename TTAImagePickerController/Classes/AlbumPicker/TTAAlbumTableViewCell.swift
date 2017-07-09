//
//  TTAAlbumTableViewCell.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import Photos

class TTAAlbumTableViewCell: UITableViewCell {
    
    struct AlbumTableViewCellConst {
        let imageViewLeftMargin: CGFloat = 16
        let imageViewRightMargin: CGFloat = 10
        let imageViewTopMargin: CGFloat = 10
        let imageViewBottomMargin: CGFloat = 10
    }
    
    var assetID = ""
    var imageRequestID: PHImageRequestID = 0
    
    fileprivate let previewImageView = UIImageView()
    
    fileprivate let const = AlbumTableViewCellConst()
    
    var album: TTAAlbum? {
        didSet {
            previewImageView.image = nil
            
            guard let album = album else { return }
            textLabel?.text = album.name()
            detailTextLabel?.text = String(describing: album.assetCount())
            
            album.requestThumbnail(with: 0, size: previewImageView.bounds.size.toPixel()) { [weak self] (image) in
                guard let `self` = self else { return }
                self.previewImageView.image = image;
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        _configViews()
        _layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutViews()
    }
}

// MARK: - UI

extension TTAAlbumTableViewCell {
    
    func _configViews() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        
        contentView.addSubview(previewImageView)
        
        detailTextLabel?.textColor = .lightGray
        accessoryType = .disclosureIndicator
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
    }
    
    func _layoutViews() {
        let height = contentView.bounds.height - const.imageViewTopMargin - const.imageViewBottomMargin
        let width = height
        previewImageView.frame = CGRect(x: const.imageViewLeftMargin, y: const.imageViewTopMargin, width: width, height: height)
        previewImageView.center.y = contentView.center.y
        
        let textLabelX = previewImageView.frame.maxX + const.imageViewRightMargin
        textLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.y += 5
    }
}
