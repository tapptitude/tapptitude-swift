//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    @IBInspectable var rounded : Bool = true
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor:layer.borderColor!) : nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if rounded {
            self.cornerRadius = bounds.size.height * 0.5
        }
    }
}
