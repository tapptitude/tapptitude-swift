//
//  ReversedFlowLayout.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 31/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

class ReversedFlowLayout: UICollectionViewFlowLayout {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView!.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return RotatedLayoutAttribute.self
    }
    
    override func prepare() {
        super.prepare()
        
        collectionView!.transform = CGAffineTransform(rotationAngle: .pi)
        collectionView!.scrollIndicatorInsets.right = collectionView!.bounds.width - 8
    }
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if itemIndexPath == IndexPath(item: 0, section: 0) && collectionView?.visibleCells.isEmpty == false {
            attributes?.alpha = 1.0
            attributes?.transform = attributes!.transform.translatedBy(x: 0, y: -attributes!.bounds.height)
        }
        return attributes
    }
}


public class RotatedLayoutAttribute: UICollectionViewLayoutAttributes {
    
    override public init() {
        super.init()
        
        self.transform = CGAffineTransform(rotationAngle: .pi)
    }
}
