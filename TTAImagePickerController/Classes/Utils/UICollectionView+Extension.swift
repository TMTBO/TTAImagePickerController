//
//  UICollectionView+Extension.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 09/07/2017.
//

import UIKit

extension UICollectionView {
    
    /// Find the near IndexPaths around `cell` in `section` with `sideCount` pre side
    /// `isContainCurrent` default is `false`, if `true` the result while incloud the current cell indexPath
    func nearIndexPaths(for cell: UICollectionViewCell, in section: Int, sideCount: Int, isContainCurrent: Bool = false) -> [IndexPath] {
        guard let currentIndexPath = indexPath(for: cell) else { return [] }
        var nearItems = [IndexPath]()
        for offset in -sideCount...sideCount {
            let index = currentIndexPath.item + offset
            if index == currentIndexPath.item && !isContainCurrent {
                continue
            }
            if index >= 0 && index < numberOfItems(inSection: section) {
                nearItems.append(IndexPath(item: index, section: section))
            }
        }
        return nearItems
    }
}
