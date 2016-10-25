//
//  KeyboardVisibilityController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

open class KeyboardVisibilityController: NSObject {
    
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
    
    open var additionallAnimatioBlock: ((_ moveUp: Bool) -> Void)? //view properties to be animated
    open var disableKeyboardMoveUpAnimation: Bool = false
    open var keyboardVisible: Bool = false
    
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
    
    func keyboardWillAppear(_ notification: Notification) {
        self.keyboardVisible = true
        self.dismissKeyboardTouchRecognizer?.isEnabled = true
        self.moveViewUp(true, usingKeyboardNotification: notification)
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        self.keyboardVisible = false
        self.dismissKeyboardTouchRecognizer?.isEnabled = false
        self.moveViewUp(false, usingKeyboardNotification: notification)
    }
    
    func applicationWillResign(_ notification: Notification) {
        self.view?.endEditing(true)
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        //        var userInfo: [NSObject : AnyObject] = notification.userInfo!
        //        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        ////        let goingUp = keyboardEndFrame.size.height == 0; //COMMENTED
        self.moveViewUp(true, usingKeyboardNotification: notification)
    }
    
    func moveViewUp(_ up: Bool, usingKeyboardNotification notification: Notification) {
        if self.view == nil || self.view?.window == nil {
            return //ingore
        }
        
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
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
            let frame = visibleView.convert(visibleView.bounds, to: visibleView.window)
            
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
            let frame = scrollView.convert(scrollView.bounds, to: scrollView.window)
            let diff = scrollView.window!.bounds.size.height - frame.maxY
            
            let key = "previousInsetBottom"
            var inset = scrollView.contentInset
            if up {
                if scrollView.layer.value(forKey: key) == nil {
                    scrollView.layer.setValue(inset.bottom, forKey: key)
                }
                inset.bottom = keyboardEndFrame!.size.height - diff;
            } else {
                inset.bottom = CGFloat((scrollView.layer.value(forKey: key)! as AnyObject).floatValue)
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
            self.view?.transform = up ? CGAffineTransform(translationX: 0, y: -moveUpValue) : CGAffineTransform.identity
        }
        
        additionallAnimatioBlock?(up)
        
        if !self.disableKeyboardMoveUpAnimation {
            UIView.commitAnimations()
        }
    }
    
    func dismissFirstResponder(_ sender: AnyObject) {
        self.view?.findFirstResponder()?.resignFirstResponder()
    }
}

import ObjectiveC
public extension UIView {
    
    fileprivate struct KeyboardAssociatedKey {
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
