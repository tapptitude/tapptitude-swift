//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceholderTextField : UITextField {
    @IBInspectable var placeholderColor: UIColor = UIColor.lightTextColor()
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
        placeholderLabel.userInteractionEnabled = false
        placeholderLabel.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        placeholderLabel.layer.zPosition = 1
        
        self.addSubview(placeholderLabel)
    }
    
    // placeholderColor
    override func drawPlaceholderInRect(rect: CGRect) {
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
        
        if text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let scaleValue = 0.6 as CGFloat
            let scale = CGAffineTransformMakeScale(scaleValue, scaleValue);
            let size = placeholderLabel.bounds.size
            let translate = CGAffineTransformMakeTranslation(-size.width * (1.0 - scaleValue) * 0.5, -size.height * (1.1 - scaleValue))
            let transform = CGAffineTransformConcat(scale, translate)
            
            placeholderLabel.textColor = placeholderSmallColor ?? placeholderColor
            
            if CGAffineTransformIsIdentity(placeholderLabel.transform)  && self.window != nil {
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    self.placeholderLabel.transform = transform
                }, completion: nil)
            } else {
                placeholderLabel.transform = transform
            }
        } else {
            placeholderLabel.textColor = placeholderColor
            if !CGAffineTransformIsIdentity(placeholderLabel.transform)  && self.window != nil {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.placeholderLabel.transform = CGAffineTransformIdentity
                });
            } else {
                placeholderLabel.transform = CGAffineTransformIdentity
            }
        }
    }
}