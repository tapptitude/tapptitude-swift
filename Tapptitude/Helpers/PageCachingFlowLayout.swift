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
    

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !enableCachingOfAdiacentCells {
            return super.layoutAttributesForElements(in: rect)
        }

        let biggerRect = UIEdgeInsetsInsetRect(rect, cachingInset)
        let isHorizontalScrolling = self.scrollDirection == .horizontal
        
        let bounds = self.collectionView?.bounds
        let attributes = super.layoutAttributesForElements(in: biggerRect)
        var newAttributes: [UICollectionViewLayoutAttributes] = []
        
        if let attributes = attributes, let bounds = bounds {
            for oldAttribute: UICollectionViewLayoutAttributes in attributes {
                let attribute = oldAttribute.copy() as! UICollectionViewLayoutAttributes
                
                var diff: CGFloat = 0.0
                if isHorizontalScrolling {
                    if bounds.maxX <= attribute.frame.origin.x {
                        diff = bounds.maxX - attribute.frame.minX - 1.0
                        attribute.alpha = 0.0
                        attribute.frame = attribute.frame.offsetBy(dx: diff, dy: 0)
                    } else if bounds.origin.x >= attribute.frame.maxX {
                        diff = bounds.minX - attribute.frame.maxX + 1.0
                        attribute.alpha = 0.0
                        attribute.frame = attribute.frame.offsetBy(dx: diff, dy: 0)
                    }
                } else { //vertical
                    if bounds.maxY <= attribute.frame.origin.y {
                        diff = bounds.maxY - attribute.frame.minY - 1.0
                        attribute.alpha = 0.0
                        attribute.frame = attribute.frame.offsetBy(dx: 0, dy: diff)
                    } else if bounds.origin.y >= attribute.frame.maxY {
                        diff = bounds.minY - attribute.frame.maxY + 1.0
                        attribute.alpha = 0.0
                        attribute.frame = attribute.frame.offsetBy(dx: 0, dy: diff)
                    }
                }
                
                newAttributes.append(attribute)
            }
        }
        
        return newAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return enableCachingOfAdiacentCells
    }
}
