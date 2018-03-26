//
//  ChatCollectionViewFlowLayout.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 31/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit


public class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var visibleCells: [VisibleCell]?
    private class VisibleCell {
        var indexPath: IndexPath
        var frame: CGRect
        
        init(indexPath: IndexPath, frame: CGRect) {
            self.indexPath = indexPath
            self.frame = frame
        }
    }
    
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = self.collectionView else {
            return
        }
        
        // track only cell
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        visibleCells = visibleIndexPaths.map({ VisibleCell(indexPath: $0, frame: collectionView.cellForItem(at: $0)!.frame) })
        
        var shouldChangeOffset = false
        
        for item in updateItems {
            switch item.updateAction {
            case .insert:
                // increase index +1 for items in same section
                visibleCells?.filter({ $0.indexPath.section == item.indexPathAfterUpdate!.section && item.indexPathAfterUpdate!.item <= $0.indexPath.item }).forEach({
                    $0.indexPath = IndexPath(item: $0.indexPath.item + 1, section: $0.indexPath.section)
                    shouldChangeOffset = true
                })
            case .delete:
                // remove deleted attributes
                visibleCells = visibleCells?.filter({ $0.indexPath == item.indexPathBeforeUpdate })
                
                // decrease index -1 for items in same section
                visibleCells?.filter({ $0.indexPath.section == item.indexPathBeforeUpdate!.section && item.indexPathBeforeUpdate!.item < $0.indexPath.item  }).forEach({
                    $0.indexPath = IndexPath(item: $0.indexPath.item - 1, section: $0.indexPath.section)
                    shouldChangeOffset = true
                })
            case .move: break
            case .reload: break
            case .none: break
            }
        }
        
        if !shouldChangeOffset {
            visibleCells = [] // no need to change offset
        }
        
        super.prepare(forCollectionViewUpdates: updateItems)
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        var offsetDiff: CGFloat = 0.0
        let pageHeight = collectionView.bounds.height - collectionView.contentInset.bottom - collectionView.contentInset.top
        if let oldAttribute = visibleCells?.first, collectionViewContentSize.height > pageHeight  {
            let newAttribute = layoutAttributesForItem(at: oldAttribute.indexPath)!
            offsetDiff = newAttribute.frame.minY - oldAttribute.frame.minY
            
            //            offsetDiff = collectionViewContentSize.height - collectionView.contentSize.height
        }
        
        // on new content, keep bottom part of content in visible area
        //        let conteSizeLessThanFirstPage = collectionView.contentSize.height <= collectionView.bounds.height {
        if collectionView.contentSize.height == 0.0 && collectionViewContentSize.height > pageHeight {
            let newOffsetY = collectionViewContentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom
            let oldOffsetY = collectionView.contentOffset.y
            offsetDiff = newOffsetY - oldOffsetY
        }
        
        if offsetDiff != 0.0 {
            collectionView.subviews.forEach({ $0.layer.removeAllAnimations() })
            
            let context = UICollectionViewFlowLayoutInvalidationContext()
            context.contentOffsetAdjustment = CGPoint(x: 0, y: offsetDiff)
            
            UIView.performWithoutAnimation {
                self.invalidateLayout(with: context)
            }
        }
    }
}
