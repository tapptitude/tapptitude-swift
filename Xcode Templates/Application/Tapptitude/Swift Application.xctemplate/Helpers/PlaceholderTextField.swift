//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


@IBDesignable
class PlaceholderTextField : UITextField {
    @IBInspectable var placeholderColor: UIColor = UIColor.lightText
    @IBInspectable var placeholderSmallColor: UIColor?
    var placeholderLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        self.bringSubviewToFront(placeholderLabel)
        self.clipsToBounds = false
        setupPlaceholder()
    }
    
    override func prepareForInterfaceBuilder() {
        setupPlaceholder()
    }
    
    func setupPlaceholder() {
        placeholderLabel.frame = self.bounds
        placeholderLabel.text = self.placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = self.font
        placeholderLabel.textAlignment = self.textAlignment
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        placeholderLabel.layer.zPosition = 1
        
        self.addSubview(placeholderLabel)
    }
    
    // placeholderColor
    override func drawPlaceholder(in rect: CGRect) {
        //        let attribute = self.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString
        //        attribute?.addAttribute(NSForegroundColorAttributeName, value: self.placeholderColor, range: NSMakeRange(0, attribute!.length))
        //        self.attributedPlaceholder = attribute
        //        super.drawPlaceholderInRect(rect)
    }
    
    //    override func editingRectForBounds(bounds: CGRect) -> CGRect {
    //        return CGRectOffset(bounds, 0, 5)
    //    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            let scaleValue = 0.6 as CGFloat
            let scale = CGAffineTransform(scaleX: scaleValue, y: scaleValue);
            let size = placeholderLabel.bounds.size
            let translate = CGAffineTransform(translationX: -size.width * (1.0 - scaleValue) * 0.5, y: -size.height * (1.1 - scaleValue))
            let transform = scale.concatenating(translate)
            
            placeholderLabel.textColor = placeholderSmallColor ?? placeholderColor
            
            if placeholderLabel.transform.isIdentity  && self.window != nil {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                    self.placeholderLabel.transform = transform
                }, completion: nil)
            } else {
                placeholderLabel.transform = transform
            }
        } else {
            placeholderLabel.textColor = placeholderColor
            if !placeholderLabel.transform.isIdentity  && self.window != nil {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.placeholderLabel.transform = CGAffineTransform.identity
                });
            } else {
                placeholderLabel.transform = CGAffineTransform.identity
            }
        }
    }
}
