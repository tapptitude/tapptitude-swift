//
//  ReversedFlowLayout.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 31/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

public class ChatFlowLayout: UICollectionViewFlowLayout {
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView!.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return RotatedLayoutAttribute.self
    }
    
    override public func prepare() {
        super.prepare()
        
        collectionView!.transform = CGAffineTransform(rotationAngle: .pi)
        collectionView!.scrollIndicatorInsets.right = collectionView!.bounds.width - 8
        
        let diff = collectionViewContentSize.height - (collectionView!.bounds.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom)
        if diff < 0 {
            let invalidation = UICollectionViewFlowLayoutInvalidationContext()
            invalidation.invalidateFlowLayoutDelegateMetrics = false
            invalidation.invalidateFlowLayoutAttributes = false
            invalidation.contentSizeAdjustment = CGSize(width: 0, height: -diff)
            self.invalidateLayout(with: invalidation)
            self.sectionInset.top = -diff
            super.prepare()
        }
    }
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if itemIndexPath == IndexPath(item: 0, section: 0) && collectionView?.visibleCells.isEmpty == false {
            attributes?.alpha = 1.0
            attributes?.transform = attributes!.transform.translatedBy(x: 0, y: -attributes!.bounds.height)
        }
//        applyTranslationFixFor(attribute: attributes!)
        return attributes
    }
    
//    func applyTranslationFixFor(attribute: UICollectionViewLayoutAttributes) {
//        let diff = collectionViewContentSize.height - (collectionView!.bounds.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom)
//        if diff < 0 {
//            attribute.transform = attribute.transform.translatedBy(x: 0, y: diff)
//        }
//    }
    
//    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)
//        attributes?.forEach(applyTranslationFixFor(attribute:))
//        return attributes
//    }
}


public class RotatedLayoutAttribute: UICollectionViewLayoutAttributes {
    
    override public init() {
        super.init()
        
        self.transform = CGAffineTransform(rotationAngle: .pi)
    }
}
