//
//  KeyboardVisibilityController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

public class KeyboardVisibilityController: NSObject {
    
    public weak var view: UIView? // this view will be translated up, will make firstResponder visible
    public weak var toBeVisibleView: UIView? //when keyboard is visible move this view up
    
    public var dismissKeyboardTouchRecognizer: TouchRecognizer? { //nil by default
        willSet {
            if let touchRecognizer = self.dismissKeyboardTouchRecognizer {
                touchRecognizer.view?.removeGestureRecognizer(touchRecognizer)
            }
        }
    }
    public var moveViewUpByValue: CGFloat = 0 // move by a exact value, when 0 view is moved up by keyboard height
    public var addMoveUpValue: CGFloat = 0 // you can add extra height
    public var makeFirstRespondeSuperviewVisible: Bool = false //instead of firstResponder view
    
    public var additionallAnimatioBlock: ((moveUp: Bool) -> Void)? //view properties to be animated
    public var disableKeyboardMoveUpAnimation: Bool = false
    public var keyboardVisible: Bool = false
    
    public override init() {
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
    
    convenience public init(viewToMove moveView: UIView) {
        self.init()
        self.view = moveView
    }
    
    deinit {
        if let touchRecognizer = self.dismissKeyboardTouchRecognizer {
            touchRecognizer.view?.removeGestureRecognizer(touchRecognizer)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - keyboard events
    
    func keyboardWillAppear(notification: NSNotification) {
        self.keyboardVisible = true
        self.dismissKeyboardTouchRecognizer?.enabled = true
        self.moveViewUp(true, usingKeyboardNotification: notification)
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
        if self.view == nil || self.view?.window == nil {
            return //ingore
        }
        
        let userInfo = notification.userInfo!
        let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        
        var toBeVisibleView = self.toBeVisibleView
        
        if toBeVisibleView == nil {
            toBeVisibleView = self.view?.findFirstResponder()
            if self.makeFirstRespondeSuperviewVisible {
                toBeVisibleView = toBeVisibleView?.superview
            }
        }
        
        // the old way of animation will match the keyboard animation timing and curve
        if !self.disableKeyboardMoveUpAnimation {
            UIView.beginAnimations(nil, context: nil)
            if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                UIView.setAnimationDuration(duration)
            }
            if let animationValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int {
                if let animationCurve = UIViewAnimationCurve(rawValue: animationValue) {
                    UIView.setAnimationCurve(animationCurve)
                }
            }
            UIView.setAnimationBeginsFromCurrentState(true)
        }
        
        var moveUpValue: CGFloat = self.moveViewUpByValue
        if let visibleView = toBeVisibleView {
            let frame = visibleView.convertRect(visibleView.bounds, toView: visibleView.window)
            
            if let endFrame = keyboardEndFrame {
                let deltaY = frame.maxY - endFrame.origin.y
                let shouldMove = (deltaY - self.view!.transform.ty) > 0
                if shouldMove {
                    moveUpValue = deltaY - self.view!.transform.ty
                }
            }
        }
        moveUpValue += addMoveUpValue
        
        if let scrollView = self.view as? UIScrollView{
            let frame = scrollView.convertRect(scrollView.bounds, toView: scrollView.window)
            let diff = scrollView.window!.bounds.size.height - frame.maxY
            
            let key = "previousInsetBottom"
            var inset = scrollView.contentInset
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
            self.view?.transform = up ? CGAffineTransformMakeTranslation(0, -moveUpValue) : CGAffineTransformIdentity
        }
        
        additionallAnimatioBlock?(moveUp: up)
        
        if !self.disableKeyboardMoveUpAnimation {
            UIView.commitAnimations()
        }
    }
    
    func dismissFirstResponder(sender: AnyObject) {
        self.view?.findFirstResponder()?.resignFirstResponder()
    }
}

import ObjectiveC
public extension UIView {
    
    private struct KeyboardAssociatedKey {
        static var viewExtension = "viewExtensionKeyboardVisibilityController"
    }
    
    public var keyboardVisibilityController: KeyboardVisibilityController? {
        get {
            return objc_getAssociatedObject(self, &KeyboardAssociatedKey.viewExtension) as? KeyboardVisibilityController ?? nil
        }
        set {
            objc_setAssociatedObject(self, &KeyboardAssociatedKey.viewExtension, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func addKeyboardVisibilityController() -> KeyboardVisibilityController {
        var keyboardController = self.keyboardVisibilityController
        
        if keyboardController == nil {
            keyboardController = KeyboardVisibilityController(viewToMove: self)
            keyboardController?.dismissKeyboardTouchRecognizer = TouchRecognizer(target: keyboardController, action: #selector(KeyboardVisibilityController.dismissFirstResponder))
            keyboardController?.dismissKeyboardTouchRecognizer?.ignoreFirstResponder = true
            keyboardController?.dismissKeyboardTouchRecognizer?.enabled = false
            
            if let touchKeyboard = keyboardController?.dismissKeyboardTouchRecognizer {
                self.addGestureRecognizer(touchKeyboard)
            }
            
            self.keyboardVisibilityController = keyboardController
        }
        
        return keyboardVisibilityController!
    }
    
    public func removeKeyboardVisibilityController() {
        keyboardVisibilityController = nil
    }
}

public extension UIView {
    
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