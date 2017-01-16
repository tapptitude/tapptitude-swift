//
//  TextCell.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 23/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class TextCell : UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if #available(iOS 9.0, *) {
            return preferredLayoutAttributesFitting_VerticalResizing(layoutAttributes)
        } else {
            // Fallback on earlier versions
            return layoutAttributes
        }
    }
    
}
