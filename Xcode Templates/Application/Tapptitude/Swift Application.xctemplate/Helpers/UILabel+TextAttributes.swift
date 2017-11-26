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
    func add(_ attributes: TextAttributes, forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    newAttributes.addAttributes(attributes, range: newAttributes.string.nsRange(from: range))
                    self.attributedText = newAttributes
                }
            }
        }
    }
}

extension UILabel {
    func add(_ attributes: TextAttributes, forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    newAttributes.addAttributes(attributes, range: newAttributes.string.nsRange(from: range))
                    self.attributedText = newAttributes
                }
            }
        }
    }
    
    func append(_ string: String?, attributes: TextAttributes) {
        if let string = string {
            if let oldAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                let newAttributes = NSAttributedString(string: string, attributes: attributes)
                oldAttributes.append(newAttributes)
                self.attributedText = newAttributes
            }
        }
    }
}


extension UIButton {
    func underline() {
        let attrs = TextAttributes().font(self.titleLabel!.font)
        attrs.underlineStyle = .styleSingle
        
        let attributedString = NSAttributedString(string: self.titleLabel!.text!, attributes: attrs)
        self.setAttributedTitle(attributedString, for: .normal)
    }
}


extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)
        let to = range.upperBound.samePosition(in: utf16view)
        return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from!),
                           utf16view.distance(from: from!, to: to!))
    }
}

