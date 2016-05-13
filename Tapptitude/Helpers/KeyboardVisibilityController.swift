//
//  KeyboardVisibilityController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

class KeyboardVisibilityController: NSObject {

    weak var view: UIView? // this view will be translated up, will make firstResponder visible
    weak var toBeVisibleView: UIView? //when keyboard is visible move this view up
    
    var dismissKeyboardTouchRecognizer: TouchRecognizer? = nil //nil by default
    var moveViewUpByValue: Float? // move by a exact value, when 0 view is moved up by keyboard height
    var makeFirstRespondeSuperviewVisible: Bool? //instead of firstResponder view
    
    var additionallAnimatioBlock: ((moveUp: Bool) -> Void)? //view properties to be animated
    var disableKeyboardMoveUpAnimation: Bool = false
    var keyboardVisible: Bool = false
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillAppear),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillDisappear),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.applicationWillResign),
                                                         name: UIApplicationWillResignActiveNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillChangeFrame),
                                                         name: UIKeyboardWillChangeFrameNotification,
                                                         object: nil)
    }

    init(viewToMove moveView: UIView) {
        self.view = moveView
    }
    
    deinit {
        if self.dismissKeyboardTouchRecognizer != nil {
            self.dismissKeyboardTouchRecognizer!.view?.removeGestureRecognizer(self.dismissKeyboardTouchRecognizer!)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - keyboard events
    
    func keyboardWillAppear(notification: NSNotification) {
        self.dismissKeyboardTouchRecognizer?.enabled = true
        self.keyboardVisible = true
        self.moveViewUp(false, usingKeyboardNotification: notification)
    }

    func keyboardWillDisappear(notification: NSNotification) {
        self.keyboardVisible = false
        self.dismissKeyboardTouchRecognizer?.enabled = false
        self.moveViewUp(false, usingKeyboardNotification: notification)
    }
    
    func applicationWillResign(notification: NSNotification) {
        self.view?.endEditing(true)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
//        var userInfo: [NSObject : AnyObject] = notification.userInfo!
//        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
////        let goingUp = keyboardEndFrame.size.height == 0; //COMMENTED
        self.moveViewUp(true, usingKeyboardNotification: notification)
    }
    
    func moveViewUp(up: Bool, usingKeyboardNotification notification: NSNotification) {
        if self.view == nil {
            return
        }
        
        let userInfo = notification.userInfo!
//        var animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
//        var animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.integerValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        
        var toBeVisibleView = self.toBeVisibleView
        
        if toBeVisibleView == nil {
            toBeVisibleView = self.view?.findFirstResponder()
            
            if let makeVisible = self.makeFirstRespondeSuperviewVisible {
                if makeVisible {
                    toBeVisibleView = toBeVisibleView?.superview
                }
            }
        }
        
        // the old way of animation will match the keyboard animation timing and curve
        if !self.disableKeyboardMoveUpAnimation {
            UIView.beginAnimations(nil, context: nil)
            
            if let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                UIView.setAnimationDuration(duration)
            }
            
            if let animationValue = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.integerValue {
                if let animationCurve = UIViewAnimationCurve(rawValue: animationValue) {
                    UIView.setAnimationCurve(animationCurve)
                }
            }
            
            UIView.setAnimationBeginsFromCurrentState(true)
        }
    
        var moveUpValue: CGFloat = 0
        if let value = self.moveViewUpByValue {
            moveUpValue = CGFloat(value)
        }
        
        if let visibleView = toBeVisibleView {
            let frame = visibleView.convertRect(visibleView.bounds, toView: visibleView.window)
            
            if let endFrame = keyboardEndFrame {
                let deltaY = CGRectGetMaxY(frame) - endFrame.origin.y
                let shouldMove = (deltaY - self.view!.transform.ty) > 0
                if shouldMove {
                    moveUpValue = deltaY - self.view!.transform.ty
                }
            }
        }
        
        if let scrollView = self.view as? UIScrollView{
            let frame = scrollView.convertRect(scrollView.bounds, toView: scrollView.window)
            let diff = scrollView.window!.bounds.size.height - CGRectGetMaxY(frame)
            
            let key = "previousInsetBottom"
            var inset = scrollView.alignmentRectInsets()
            
            if up {
                if scrollView.layer.valueForKey(key) == nil {
                    scrollView.layer.setValue(inset.bottom, forKey: key)
                }
                inset.bottom = keyboardEndFrame!.size.height - diff;
            } else {
                inset.bottom = CGFloat(scrollView.layer.valueForKey(key)!.floatValue)
            }
            
            scrollView.contentInset = inset
            var indicatorInset = scrollView.scrollIndicatorInsets
            indicatorInset.bottom = inset.bottom
            scrollView.scrollIndicatorInsets = indicatorInset
            
            if up {
                let newY = scrollView.contentOffset.y + (up ? moveUpValue : 0)
                scrollView.contentOffset = CGPointMake(0, newY)
            }
        } else {
            self.view?.transform = up ? CGAffineTransformMakeTranslation(0, -moveUpValue):CGAffineTransformIdentity
        }
        
        if let additionalBlock = self.additionallAnimatioBlock {
            additionalBlock(moveUp: up)
        }
        
        if !self.disableKeyboardMoveUpAnimation {
            UIView.commitAnimations()
        }
    }
    
    func dismissFirstResponder(sender: AnyObject) {
        self.view?.findFirstResponder()?.resignFirstResponder()
    }
    
    func setDismissTTKeyboardTouchRecognizer(dismissKeyboardTouchRecognizer: TouchRecognizer?) {
        if (self.dismissKeyboardTouchRecognizer != nil) && (dismissKeyboardTouchRecognizer == nil) {
            self.dismissKeyboardTouchRecognizer?.view?.removeGestureRecognizer(self.dismissKeyboardTouchRecognizer!)
            
            self.dismissKeyboardTouchRecognizer = dismissKeyboardTouchRecognizer
        }
    }
}

import ObjectiveC
extension UIView {
    
    private struct KeyboardAssociatedKey {
        static var viewExtension = "viewExtensionKeyboardVisibilityController"
    }
    
    var keyboardVisibilityController: KeyboardVisibilityController? {
        get {
            return objc_getAssociatedObject(self, &KeyboardAssociatedKey.viewExtension) as? KeyboardVisibilityController ?? nil
        }
        set {
            objc_setAssociatedObject(self, &KeyboardAssociatedKey.viewExtension, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func addKeyboardVisibilityController() -> KeyboardVisibilityController? {
        var keyboardController = self.keyboardVisibilityController
        
        if keyboardController == nil {
            keyboardController = KeyboardVisibilityController(viewToMove: self)
            keyboardController?.dismissKeyboardTouchRecognizer = UIGestureRecognizer.init(target: keyboardController, action: #selector(KeyboardVisibilityController.dismissFirstResponder)) as? TouchRecognizer
            keyboardController?.dismissKeyboardTouchRecognizer?.ignoreFirstResponder = true
            keyboardController?.dismissKeyboardTouchRecognizer?.enabled = false
            
            if let touchKeyboard = keyboardController?.dismissKeyboardTouchRecognizer {
                self.addGestureRecognizer(touchKeyboard)
            }
            
            self.keyboardVisibilityController = keyboardController
        }
        
        return keyboardController
    }
    
    func removeKeyboardVisibilityController() {
        keyboardVisibilityController = nil
    }
}

extension UIView {
    
    public func findFirstResponder() -> UIView? {
        if isFirstResponder() {
            return self
        }
        
        for subView in subviews {
            if subView.isFirstResponder() {
                return subView
            }
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}