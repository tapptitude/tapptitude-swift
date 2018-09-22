//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


extension NSAttributedString {
    func replacing(key: String, with valueString: String) -> NSAttributedString {
        if let range = self.string.range(of: key) {
            let nsRange = self.string.nsRange(from: range)
            let mutableText = NSMutableAttributedString(attributedString: self)
            mutableText.replaceCharacters(in: nsRange, with: valueString)
            return mutableText as NSAttributedString
        }
        return self
    }
}

extension UITextView {
    func add(_ attributes: [NSAttributedString.Key:Any], forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    let nsRange = NSRange(range,in:string)
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
}

extension UILabel {
    func add(_ attributes: [NSAttributedString.Key:Any], forString string: String?, options: NSString.CompareOptions = .caseInsensitive) {
        if let string = string {
            if let newAttributes = attributedText?.mutableCopy() as? NSMutableAttributedString {
                if let range = newAttributes.string.range(of: string, options: options) {
                    let nsRange = NSRange(range,in:string)
                    newAttributes.addAttributes(attributes, range: nsRange)
                    self.attributedText = newAttributes
                }
            }
        }
    }
    
    func append(_ string: String?, attributes: [NSAttributedString.Key:Any]) {
        if let string = string {
            if let attributedString = attributedText?.mutableCopy() as? NSMutableAttributedString {
                let newAttributedString = NSAttributedString(string: string, attributes: attributes)
                attributedString.append(newAttributedString)
                self.attributedText = attributedString
            }
        }
    }
}

extension UILabel  {
    func replaceAttributedText(placeholder: String, with valueString: String) {
        attributedText = attributedText?.replacing(key: placeholder, with: valueString)
    }
}


extension UIButton {
    func underline() {
        let attrs:[NSAttributedString.Key:Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedString = NSAttributedString(string: self.titleLabel!.text!, attributes: attrs)
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)!
        let to = range.upperBound.samePosition(in: utf16view)!
        return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from),
                           utf16view.distance(from: from, to: to))
    }
}

