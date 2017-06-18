//
//  TTAAssetCollectionTableViewCell.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit

class TTAAssetCollectionTableViewCell: UITableViewCell {
    
    struct AssetCollectionTableViewCellConst {
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
            _ = TTAImagePickerManager.fetchImage(for: asset,
                                            size: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionSize,
                                     contentMode: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionContentMode,
                                         options: TTAImagePickerManager.AssetCollectionManagerConst.assetCollectionRequestOptions) { [weak self] (image, _) in
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

extension TTAAssetCollectionTableViewCell {
    
    func _configViews() {
        contentView.addSubview(previewImageView)
        
        detailTextLabel?.textColor = .lightGray
        accessoryType = .disclosureIndicator
    }
    
    func _layoutViews() {
        let height = contentView.bounds.height - AssetCollectionTableViewCellConst.imageViewTopMargin - AssetCollectionTableViewCellConst.imageViewBottomMargin
        let width = height
        previewImageView.frame = CGRect(x: AssetCollectionTableViewCellConst.imageViewLeftMargin, y: AssetCollectionTableViewCellConst.imageViewTopMargin, width: width, height: height)
        previewImageView.center.y = contentView.center.y
        
        let textLabelX = previewImageView.frame.maxX + AssetCollectionTableViewCellConst.imageViewRightMargin
        textLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.x = textLabelX
        detailTextLabel?.frame.origin.y += 5
    }
}
