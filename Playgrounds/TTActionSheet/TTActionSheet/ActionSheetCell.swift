//
//  ActionSheetCell.swift
//  test
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit
import Tapptitude




class ActionSheetCell: UICollectionViewCell {
    var content:TTActionSheetAction!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionButton.setBackgroundImage(imageFromColor(UIColorFromRGB(0xBBBBBF)), forState: .Highlighted)
    }
    @IBAction func selectedAction(sender: AnyObject) {
        content.handler?()
        let parent = self.parentViewController as! TTActionSheet
        parent.cancelAction(self)
    }
}
