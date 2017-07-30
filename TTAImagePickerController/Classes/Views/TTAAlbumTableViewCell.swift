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
    
    fileprivate let previewImageView = UIImageView()
    fileprivate let videoMarkLabel = UILabel()
    
    fileprivate let const = AlbumTableViewCellConst()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configViews()
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

extension TTAAlbumTableViewCell {
    
    func configViews() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        
        contentView.addSubview(previewImageView)
        contentView.addSubview(videoMarkLabel)
        
        detailTextLabel?.textColor = .lightGray
        accessoryType = .disclosureIndicator
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        videoMarkLabel.font = UIFont.iconfont(size: UIFont.IconFontSize.videoMark)
        videoMarkLabel.text = UIFont.IconFont.videoMark.rawValue
        videoMarkLabel.textColor = .white
    }
    
    func layoutViews() {
        let height = contentView.bounds.height - const.imageViewTopMargin - const.imageViewBottomMargin
        let width = height
        previewImageView.frame = CGRect(x: const.imageViewLeftMargin, y: const.imageViewTopMargin, width: width, height: height)
        previewImageView.center.y = contentView.center.y
        
        let textLabelX = previewImageView.frame.maxX + const.imageViewRightMargin
        textLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.y += 5
        
        let videoMarkSize = UIFont.IconFontSize.videoMark
        videoMarkLabel.frame = CGRect(x: previewImageView.frame.minX + 2,
                                      y: previewImageView.frame.maxY - videoMarkSize,
                                      width: videoMarkSize,
                                      height: videoMarkSize)
    }
}

// MARK: - Public Methods

extension TTAAlbumTableViewCell {
    func update(cell tag: Int, with albumInfo: TTAAlbumInfo) {
        self.tag = tag
        textLabel?.text = albumInfo.name
        detailTextLabel?.text = albumInfo.countString
        videoMarkLabel.isHidden = !albumInfo.isVideoAlbum
    }
    
    func update(image: UIImage?) {
        previewImageView.image = image
    }
}
