//
//  ChatCollectionViewFlowLayout.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 31/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation
import UIKit


public class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var visibleAttributes: [UICollectionViewLayoutAttributes]?
    private var visibleAttributesToTrack: [UICollectionViewLayoutAttributes]?
    public var shouldChangeOffsetToKeepCellVisible = true
    
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleAttributes = super.layoutAttributesForElements(in: rect)

        return visibleAttributes
    }

    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {

        // Get collection view and layout attributes as non-optional object
        guard let collectionView = self.collectionView       else { return }

        if !shouldChangeOffsetToKeepCellVisible {
            visibleAttributes = nil
        }

        // track only cell
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        visibleAttributesToTrack = visibleAttributes?.filter({ visibleIndexPaths.contains($0.indexPath) && $0.representedElementCategory == .cell })
        var shouldChangeOffset = false

        for item in updateItems {
            switch item.updateAction {
            case .insert:
                // increase index +1 for items in same section
                visibleAttributesToTrack?.filter({ $0.indexPath.section == item.indexPathAfterUpdate!.section && item.indexPathAfterUpdate!.item <= $0.indexPath.item }).forEach({
                    $0.indexPath = IndexPath(item: $0.indexPath.item + 1, section: $0.indexPath.section)
                    shouldChangeOffset = true
                })
            case .delete:
                // remove deleted attributes
                visibleAttributesToTrack = visibleAttributesToTrack?.filter({ $0.indexPath == item.indexPathBeforeUpdate })

                // decrease index -1 for items in same section
                visibleAttributesToTrack?.filter({ $0.indexPath.section == item.indexPathBeforeUpdate!.section && item.indexPathBeforeUpdate!.item < $0.indexPath.item  }).forEach({
                    $0.indexPath = IndexPath(item: $0.indexPath.item - 1, section: $0.indexPath.section)
                    shouldChangeOffset = true
                })
            case .move: break
            case .reload: break
            case .none: break
            }
        }



        if !shouldChangeOffset {
            visibleAttributesToTrack = [] // no need to change offset
        }

        super.prepare(forCollectionViewUpdates: updateItems)
    }

    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        guard let collectionView = self.collectionView else { return }
        
        let oldOffsetY = collectionView.contentOffset.y
        var newOffsetY = oldOffsetY
        
        if let oldAttribute = visibleAttributesToTrack?.first {
            let indexPath = oldAttribute.indexPath
            let attribute = layoutAttributesForItem(at: indexPath)!
            let oldOffsetDiff = oldAttribute.frame.origin.y - collectionView.contentOffset.y
            
            newOffsetY = attribute.frame.origin.y - oldOffsetDiff
        }
        
        // on new content, keep bottom part of content in visible area
        if collectionView.contentSize.height <= collectionView.bounds.height && collectionViewContentSize.height > collectionView.bounds.height {
            newOffsetY = collectionViewContentSize.height - collectionView.bounds.height
        }
        
        if newOffsetY != oldOffsetY {
            collectionView.visibleCells.forEach({ $0.layer.removeAllAnimations() })
            
            let context = UICollectionViewFlowLayoutInvalidationContext()
            context.contentOffsetAdjustment = CGPoint(x: 0, y: newOffsetY - oldOffsetY)
            
            UIView.performWithoutAnimation {
                self.invalidateLayout(with: context)
            }
        }
    }
}
