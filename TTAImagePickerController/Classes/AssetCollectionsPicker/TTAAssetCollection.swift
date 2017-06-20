//
//  TTAAssetCollection.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

struct TTAAssetCollection {
    
    var originalCollection: PHAssetCollection!
    var assets: PHFetchResult<PHAsset>!
    var assetCollectionID: String!
    
    var assetCollectionName: String!
    var assetCount: Int = 0
    var thumbnailAsset: TTAAsset?
}
