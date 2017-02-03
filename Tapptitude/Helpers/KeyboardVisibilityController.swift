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
    
    open weak var view: UIView? // this view will be translated up, will make firstResponder visible
    open weak var toBeVisibleView: UIView? //when keyboard is visible move this view up
    
    open var dismissKeyboardTouchRecognizer: TouchRecognizer? { //nil by default
        willSet {
            if let touchRecognizer = self.dismissKeyboardTouchRecognizer {
                touchRecognizer.view?.removeGestureRecognizer(touchRecognizer)
            }
        }
    }
    open var moveViewUpByValue: CGFloat = 0 // move by a exact value, when 0 view is moved up by keyboard height
    open var addMoveUpValue: CGFloat = 0 // you can add extra height
    open var makeFirstRespondeSuperviewVisible: Bool = false //instead of firstResponder view
    
    open var additionallAnimatioBlock: ((_ moveUpValue: CGFloat) -> Void)? //view properties to be animated, 0 when returning to original value
    open var disableKeyboardMoveUpAnimation: Bool = false
    open var isKeyboardVisible: Bool = false
    open var applyTransformToVisibleView: Bool = true
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillAppear),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillDisappear),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.applicationWillResign),
                                                         name: NSNotification.Name.UIApplicationWillResignActive,
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(KeyboardVisibilityController.keyboardWillChangeFrame),
                                                         name: NSNotification.Name.UIKeyboardWillChangeFrame,
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
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - keyboard events
    
    func keyboardWillAppear(notification: Notification) {
        self.isKeyboardVisible = true
        self.dismissKeyboardTouchRecognizer?.isEnabled = true
//        self.moveViewUp(true, usingKeyboardNotification: notification)
    }
    
    func keyboardWillDisappear(notification: Notification) {
        self.isKeyboardVisible = false
        self.dismissKeyboardTouchRecognizer?.isEnabled = false
//        self.moveViewUp(false, usingKeyboardNotification: notification)
    }
    
    func applicationWillResign(notification: Notification) {
        self.view?.endEditing(true)
    }
    
    func keyboardWillChangeFrame(notification: Notification) {
        let keyboardEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let goingUp = (keyboardEndFrame?.origin.y ?? 0) < UIScreen.main.bounds.height
        self.moveViewUp(up: goingUp, usingKeyboardNotification: notification)
    }
    
    func moveViewUp(up: Bool, usingKeyboardNotification notification: Notification) {
        if self.view == nil || self.view?.window == nil {
            return //ingore
        }
        
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
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
        if let visibleView = toBeVisibleView, let endFrame = keyboardEndFrame {
            let frame = visibleView.convert(visibleView.bounds, to: visibleView.window)
            let deltaY = frame.maxY - endFrame.origin.y
            
            if applyTransformToVisibleView {
                let shouldMove = (deltaY - self.view!.transform.ty) > 0
                if shouldMove {
                    moveUpValue = deltaY - self.view!.transform.ty
                }
                moveUpValue += addMoveUpValue
            } else {
                let key = "previousMoveUpValue"
                let previousMoveUpValue = (self.view?.layer.value(forKey: key) as? CGFloat) ?? 0
                moveUpValue = deltaY + previousMoveUpValue
                moveUpValue += addMoveUpValue
                self.view?.layer.setValue(up ? moveUpValue : 0, forKey: key)
            }
        }
        
        if let scrollView = self.view as? UIScrollView {
            let frame = scrollView.convert(scrollView.bounds, to: scrollView.window)
            let diff = scrollView.window!.bounds.size.height - frame.maxY
            
            let key = "previousInsetBottom"
            var inset = scrollView.contentInset
            if up {
                if scrollView.layer.value(forKey: key) == nil {
                    scrollView.layer.setValue(inset.bottom, forKey: key)
                }
                inset.bottom = keyboardEndFrame!.size.height - diff
            } else {
                if let bottom = scrollView.layer.value(forKey: key) as? CGFloat {
                    inset.bottom = bottom
                }
            }
            
            scrollView.contentInset = inset
            var indicatorInset = scrollView.scrollIndicatorInsets
            indicatorInset.bottom = inset.bottom
            scrollView.scrollIndicatorInsets = indicatorInset
            
            if up {
                let newY = scrollView.contentOffset.y + (up ? moveUpValue : 0)
                scrollView.contentOffset = CGPoint(x: 0, y: newY)
            }
        } else {
            if applyTransformToVisibleView {
                self.view?.transform = up ? CGAffineTransform(translationX: 0, y: -moveUpValue) : CGAffineTransform.identity
            }
        }
        
        additionallAnimatioBlock?(up ? moveUpValue : 0)
        
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
    
    @discardableResult
    public func addKeyboardVisibilityController() -> KeyboardVisibilityController {
        var keyboardController = self.keyboardVisibilityController
        
        if keyboardController == nil {
            keyboardController = KeyboardVisibilityController(viewToMove: self)
            keyboardController?.dismissKeyboardTouchRecognizer = TouchRecognizer(target: keyboardController, action: #selector(KeyboardVisibilityController.dismissFirstResponder))
            keyboardController?.dismissKeyboardTouchRecognizer?.ignoreFirstResponder = true
            keyboardController?.dismissKeyboardTouchRecognizer?.isEnabled = false
            
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
        if isFirstResponder {
            return self
        }
        
        for subView in subviews {
            if subView.isFirstResponder {
                return subView
            }
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}
