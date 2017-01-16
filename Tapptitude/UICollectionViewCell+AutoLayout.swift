//
//  UICollectionViewCell+AutoLayout.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 16/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    @available(iOS 9.0, *)
    open func preferredLayoutAttributesFitting_VerticalResizing(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        fixAutolayoutConstraintsForVerticalResizing()
        
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame = CGRect(origin: layoutAttributes.frame.origin, size: CGSize(width:layoutAttributes.frame.width, height:attributes.frame.height))
        return attributes
    }
    
    fileprivate func fixAutolayoutConstraintsForVerticalResizing() {
        let isDifferentSize = contentView.bounds.size != bounds.size
        let hasConstraints = !contentView.constraints.isEmpty
        if isDifferentSize && hasConstraints {
            contentView.bounds = self.bounds
            layoutIfNeeded()
            updateLabelsPreferredMaxWidhtBaseOnFrame()
        }
    }
}

fileprivate extension UIView {
    func updateLabelsPreferredMaxWidhtBaseOnFrame() {
        subviews.flatMap{ $0 as? UILabel }.filter{ $0.preferredMaxLayoutWidth == 0 }.forEach{ $0.preferredMaxLayoutWidth = $0.bounds.width }
        subviews.forEach{ $0.updateLabelsPreferredMaxWidhtBaseOnFrame() }
    }
}

