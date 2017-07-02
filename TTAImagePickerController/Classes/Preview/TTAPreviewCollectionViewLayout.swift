//
//  TTAPreviewCollectionViewLayout.swift
//  TTAImagePickerController
//
//  Created by TobyoTenma on 02/07/2017.
//

import UIKit

class TTAPreviewCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        itemSize = CGSize(width: UIScreen.main.bounds.width + 30, height: UIScreen.main.bounds.height)
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.backgroundColor = collectionView?.superview?.backgroundColor
    }

}
