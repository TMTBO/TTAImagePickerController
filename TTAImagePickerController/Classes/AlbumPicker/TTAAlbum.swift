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
    
    var originalAlbum: PHAssetCollection!
    var assets: [TTAAsset] = []
    var albumID: String!
    
    var albumName: String!
    var assetCount: Int = 0
    var thumbnailAsset: TTAAsset?
}
