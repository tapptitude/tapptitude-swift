//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import TextAttributes

extension UITextView {
    func add(attributes: TextAttributes, forString string: String?, options: NSStringCompareOptions = .CaseInsensitiveSearch) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.rangeOfString(string, options: options) {
                    let nsRange = NSMakeRange(newAttributes.string.startIndex.distanceTo(range.startIndex), range.startIndex.distanceTo(range.endIndex))
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
}

extension UILabel {
    func add(attributes: TextAttributes, forString string: String?, options: NSStringCompareOptions = .CaseInsensitiveSearch) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.rangeOfString(string, options: options) {
                    let nsRange = NSMakeRange(newAttributes.string.startIndex.distanceTo(range.startIndex), range.startIndex.distanceTo(range.endIndex))
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
    
    func append(_ string: String?, attributes: TextAttributes) {
        if let string = string {
            if let oldAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                let newAttributes = NSAttributedString(string: string, attributes: attributes)
                oldAttributes.appendAttributedString(newAttributes)
                self.attributedText = newAttributes
            }
        }
    }
}


extension UIButton {
    func underline() {
        let attrs = TextAttributes().font(self.titleLabel!.font)
        attrs.underlineStyle = .StyleSingle
        
        let attributedString = NSAttributedString(string: self.titleLabel!.text!, attributes: attrs)
        self.setAttributedTitle(attributedString, forState: .Normal)
    }
}
