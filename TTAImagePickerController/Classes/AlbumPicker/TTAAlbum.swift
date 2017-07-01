//
//  TTAAlbum.swift
//  Pods
//
//  Created by TobyoTenma on 17/06/2017.
//
//

import UIKit
import Photos

struct TTAAlbum {
    
    var original: PHAssetCollection!
    var assets: [TTAAsset] = []
    var albumID: String!
    
    var name: String!
    var assetCount: Int = 0
    var thumbnailAsset: TTAAsset?
}
