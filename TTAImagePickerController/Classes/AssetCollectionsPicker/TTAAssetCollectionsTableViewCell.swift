//
//  TTAAssetCollectionsTableViewCell.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAssetCollectionsTableViewCell: UITableViewCell {
    
    struct AssetCollectionsTableViewCellConst {
        static let imageViewLeftMargin: CGFloat = 16
        static let imageViewRightMargin: CGFloat = 10
        static let imageViewTopMargin: CGFloat = 10
        static let imageViewBottomMargin: CGFloat = 10
    }
    
    fileprivate let previewImageView = UIImageView()
    
    var collection: TTAAssetCollection? {
        didSet {
            textLabel?.text = collection?.assetCollectionName
            detailTextLabel?.text = String(describing: (collection?.assetCount)!)
            guard let asset = collection?.thumbnailAsset?.originalAsset else { return }
            let size = TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionSize
            let contentMode = TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionContentMode
            let options = TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionRequestOptions
            _ = TTAImagePickerManager.fetchImage(for: asset, size: size, contentMode: contentMode, options: options) { [weak self] (image, info) in
                guard let isDegraded = info?["PHImageResultIsDegradedKey"] as AnyObject?, !(image == nil && !isDegraded.boolValue) else { return }
                self?.previewImageView.image = image;
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

extension TTAAssetCollectionsTableViewCell {
    
    func _configViews() {
        contentView.addSubview(previewImageView)
        
        detailTextLabel?.textColor = .lightGray
        accessoryType = .disclosureIndicator
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
    }
    
    func _layoutViews() {
        let height = contentView.bounds.height - AssetCollectionsTableViewCellConst.imageViewTopMargin - AssetCollectionsTableViewCellConst.imageViewBottomMargin
        let width = height
        previewImageView.frame = CGRect(x: AssetCollectionsTableViewCellConst.imageViewLeftMargin, y: AssetCollectionsTableViewCellConst.imageViewTopMargin, width: width, height: height)
        previewImageView.center.y = contentView.center.y
        
        let textLabelX = previewImageView.frame.maxX + AssetCollectionsTableViewCellConst.imageViewRightMargin
        textLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.y += 5
    }
}
