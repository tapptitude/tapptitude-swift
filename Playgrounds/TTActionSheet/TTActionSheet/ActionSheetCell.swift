//
//  ActionSheetCell.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude

class ActionSheetCell: UICollectionViewCell {
    var content: TTActionSheetActionProtocol!
    
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionButton.setBackgroundImage(imageFromColor(color: UIColorFromRGB(0xBBBBBF)), for: .highlighted)
    }
    
    @IBAction func selectedAction(_ sender: Any) {
        content.handler?()
        let parent = self.parentViewController as! TTActionSheet
        parent.selectedCallback?(content)
        parent.cancelAction(self)
    }
}
