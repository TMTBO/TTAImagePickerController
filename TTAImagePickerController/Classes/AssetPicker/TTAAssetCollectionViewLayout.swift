//
//  TTAAssetCollectionViewLayout.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 17/06/2017.
//

import UIKit

class TTAAssetCollectionViewLayout: UICollectionViewFlowLayout {
    
    struct TTAAssetCollectionViewLayoutConst {
        static let margin: CGFloat = 5
    }
    
    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = TTAAssetCollectionViewLayoutConst.margin
        minimumInteritemSpacing = TTAAssetCollectionViewLayoutConst.margin
        sectionInset = UIEdgeInsets(top: TTAAssetCollectionViewLayoutConst.margin, left: TTAAssetCollectionViewLayoutConst.margin, bottom: TTAAssetCollectionViewLayoutConst.margin, right: TTAAssetCollectionViewLayoutConst.margin)
        
        guard let collectionView = collectionView else { return }
        
        let columnNum: CGFloat = 3
        let width = (collectionView.bounds.width - TTAAssetCollectionViewLayoutConst.margin * (columnNum + 1)) / columnNum
        let height = width
        itemSize = CGSize(width: width, height: height)
        
        collectionView.backgroundColor = .white
    }
    
}
