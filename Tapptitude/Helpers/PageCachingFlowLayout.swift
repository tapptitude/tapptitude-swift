//
//  PageCachingFlowLayout.swift
//  Bildnytt
//
//  Created by Ion Toderasco on 01/08/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

class PageCachingFlowLayout: UICollectionViewFlowLayout {
    
    var enableCachingOfAdiacentCells: Bool = true
    var cachingInset: UIEdgeInsets = UIEdgeInsetsMake(0, -1, 0, -1)
                                    // UIEdgeInsetsMake(0, -1, 0, -1) for horizontal scrolling,
                                    // UIEdgeInsetsMake(-1, 0, -1, 0) for vertical scrolling
    

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !enableCachingOfAdiacentCells {
            return super.layoutAttributesForElementsInRect(rect)
        }

        let biggerRect = UIEdgeInsetsInsetRect(rect, cachingInset)
        let isHorizontalScrolling = self.scrollDirection == .Horizontal
        
        let bounds = self.collectionView?.bounds
        let attributes = super.layoutAttributesForElementsInRect(biggerRect)
        var newAttributes: [UICollectionViewLayoutAttributes] = []
        
        if let attributes = attributes, let bounds = bounds {
            for oldAttribute: UICollectionViewLayoutAttributes in attributes {
                let attribute = oldAttribute.copy() as! UICollectionViewLayoutAttributes
                
                var diff: CGFloat = 0.0
                if isHorizontalScrolling {
                    if CGRectGetMaxX(bounds) <= attribute.frame.origin.x {
                        diff = CGRectGetMaxX(bounds) - CGRectGetMinX(attribute.frame) - 1.0
                        attribute.alpha = 0.0
                        attribute.frame = CGRectOffset(attribute.frame, diff, 0)
                    } else if bounds.origin.x >= CGRectGetMaxX(attribute.frame) {
                        diff = CGRectGetMinX(bounds) - CGRectGetMaxX(attribute.frame) + 1.0
                        attribute.alpha = 0.0
                        attribute.frame = CGRectOffset(attribute.frame, diff, 0)
                    }
                } else { //vertical
                    if CGRectGetMaxY(bounds) <= attribute.frame.origin.y {
                        diff = CGRectGetMaxY(bounds) - CGRectGetMinY(attribute.frame) - 1.0
                        attribute.alpha = 0.0
                        attribute.frame = CGRectOffset(attribute.frame, 0, diff)
                    } else if bounds.origin.y >= CGRectGetMaxY(attribute.frame) {
                        diff = CGRectGetMinY(bounds) - CGRectGetMaxY(attribute.frame) + 1.0
                        attribute.alpha = 0.0
                        attribute.frame = CGRectOffset(attribute.frame, 0, diff)
                    }
                }
                
                newAttributes.append(attribute)
            }
        }
        
        return newAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return enableCachingOfAdiacentCells
    }
}