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
        static let defaultColumNum: CGFloat = 3
        static var correctColumNum: CGFloat = 3
        static let minimumWithAndHeight: CGFloat = 104
    }
    
    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = TTAAssetCollectionViewLayoutConst.margin
        minimumInteritemSpacing = TTAAssetCollectionViewLayoutConst.margin
        sectionInset = UIEdgeInsets(top: TTAAssetCollectionViewLayoutConst.margin, left: TTAAssetCollectionViewLayoutConst.margin, bottom: TTAAssetCollectionViewLayoutConst.margin, right: TTAAssetCollectionViewLayoutConst.margin)
        
        guard let collectionView = collectionView else { return }
        
        itemSize = itemSize(with: collectionView)
        collectionView.backgroundColor = collectionView.superview?.backgroundColor
    }
    
    func itemSize(with collectionView: UICollectionView) -> CGSize {
        let margin = TTAAssetCollectionViewLayoutConst.margin
        var count = TTAAssetCollectionViewLayoutConst.defaultColumNum
        var width: CGFloat = 0
        repeat {
            width = floor((collectionView.bounds.width - (count + 1) * margin) / count)
            count += 1
        } while (width > TTAAssetCollectionViewLayoutConst.minimumWithAndHeight)
        let height = width
        TTAAssetCollectionViewLayoutConst.correctColumNum = count - 1
        return CGSize(width: width, height: height)
    }
    
}
