//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class SeparatorView : UIView {
    var xDelta : CGFloat = 0.0
    var yDelta : CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrameSize()
    }
    
    func updateFrameSize() {
        if constraints.count == 0 {
            var width = bounds.size.width
            var height = bounds.size.height
            var xDeltaNew : CGFloat = 0.0
            var yDeltaNew : CGFloat = 0.0
            
            if width == 1.0 {
                width = width / UIScreen.main.scale
                xDeltaNew = width
            }
            
            if height == 0.0 {
                height = 1 / UIScreen.main.scale
            }
            
            if height == 1.0 {
                height = height / UIScreen.main.scale
                yDeltaNew = height
            }
            
            frame = CGRect(x: frame.origin.x + xDeltaNew - xDelta, y: frame.origin.y + yDeltaNew - yDelta, width: width, height: height);
            xDelta = xDeltaNew
            yDelta = yDeltaNew
        } else {
            for constraint in constraints {
                if (constraint.firstAttribute == .width || constraint.firstAttribute == .height) && constraint.constant == 1 {
                    constraint.constant /= UIScreen.main.scale
                }
            }
        }
    }
}
