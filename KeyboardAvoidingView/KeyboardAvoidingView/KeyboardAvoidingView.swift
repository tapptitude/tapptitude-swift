//
//  FakeKeyboardView.swift
//  DemoProject
//
//  Created by Alexandru Tudose on 13/01/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

class KeyboardAvoidingView: UIView {
    open var isKeyboardVisible: Bool = false
    public var currentKeyboardFrame: CGRect = .zero
    
    ///when keyboard is visible move this view up, toBeVisibleView == nil --> == firstResponderView
    @IBOutlet open weak var toBeVisibleView: UIView?
    @IBOutlet open weak var toInvalidateLayoutView: UIView?
    
    /// you can add extra space between keyboard and toBeVisibleView
    @IBInspectable open var extraSpaceAboveKeyboard: CGFloat = 0
    
    
     /// keep firstResponder view above keyboard
    @IBInspectable open var firstResponderVisible: Bool = false
     /// keep firstResponder superView above keyboard
    @IBInspectable open var superResponderVisible: Bool = false
    
    ///view properties to be animated, 0 when returning to original value
    open var additionallAnimatioBlock: ((_ moveUpValue: CGFloat) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResign), name: .UIApplicationWillResignActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        assert(toInvalidateLayoutView != nil, "Please connect toInvalidateLayoutView outlet --> view for which layout should be invalidated")
        assert(heightConstraint.constant == 0.0, "Height constraint is changed in response to keyboard frame changes, please add a constraint")
    }
    
    public var heightConstraint: NSLayoutConstraint! {
        return constraints.first(where: { $0.firstItem === self && $0.firstAttribute == .height
                                        || $0.secondItem === self && $0.secondAttribute == .height })
    }
    
    
    //MARK: - keyboard events
    @objc func keyboardWillAppear(notification: Notification) {
        self.isKeyboardVisible = true
    }
    
    @objc func keyboardWillDisappear(notification: Notification) {
        self.isKeyboardVisible = false
    }
    
    @objc func applicationWillResign(notification: Notification) {
        self.window?.endEditing(true)
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        let keyboardEndFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
//        guard keyboardEndFrame != currentKeyboardFrame else {
//            print("Ingnore keyboard change")
//            return
//        }
        
        currentKeyboardFrame = keyboardEndFrame!
        print("keybord Y = ", keyboardEndFrame!.minY, " height = ", keyboardEndFrame!.height)
        let goingUp = (keyboardEndFrame?.origin.y ?? 0) < UIScreen.main.bounds.height
        self.moveViewUp(up: goingUp, usingKeyboardNotification: notification)
    }
    
    func moveViewUp(up: Bool, usingKeyboardNotification notification: Notification) {
        guard let window = self.window else {
            return //ingore
        }
        
        let keyboardEndFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
        var toBeVisibleView: UIView? = self.toBeVisibleView
        
        if toBeVisibleView == nil {
            if firstResponderVisible {
                toBeVisibleView = toInvalidateLayoutView?.__findFirstResponder()
            }
            if superResponderVisible {
                toBeVisibleView = toInvalidateLayoutView?.__findFirstResponder()?.superview
            }
        }
        toBeVisibleView = toBeVisibleView ?? self
        
        
        var moveUpValue: CGFloat = 0
        if let visibleView = toBeVisibleView, let keyboardEndFrame = keyboardEndFrame, visibleView.window == window {
            if up {
                heightConstraint.constant = 0.0
                toInvalidateLayoutView?.layoutIfNeeded()
                
                let frame = visibleView.convert(visibleView.bounds, to: visibleView.window)
                print(" diff: ", frame.maxY - keyboardEndFrame.minY)
                moveUpValue = extraSpaceAboveKeyboard + (frame.maxY - keyboardEndFrame.minY)
            }
        }
        
        moveUpValue = max(0.0, moveUpValue)
        heightConstraint.constant = up ? moveUpValue : 0.0
        print(heightConstraint.constant, " up: ", up)
        print("\n")
        additionallAnimatioBlock?(moveUpValue)
        toInvalidateLayoutView?.layoutIfNeeded()
    }
}



extension UIView {
    public var keyboard: Keyboard {
        get { return Keyboard(view: self) }
    }
    
    fileprivate func __findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for subView in subviews {
            if subView.isFirstResponder {
                return subView
            }
            if let firstResponder = subView.__findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}

public final class Keyboard {
    public let view: UIView
    public init(view: UIView) {
        self.view = view
    }
    
    @discardableResult
    public func addDismissTouchRecognizer() -> KeyboardDismissTouchRecognizer {
        let view = self.view
        let touchRecognizer = KeyboardDismissTouchRecognizer(callback: { [weak view] in
            view?.window?.endEditing(true)
        })
        touchRecognizer.ignoreFirstResponder = true
        touchRecognizer.isEnabled = false
        view.addGestureRecognizer(touchRecognizer)
        
        return touchRecognizer
    }
    
    public func removeDismissTouchRecognizer(){
        if let gesture = self.dismissTouchRecognizer {
            gesture.view?.removeGestureRecognizer(gesture)
        }
    }
    
    public var dismissTouchRecognizer: KeyboardDismissTouchRecognizer? {
        return self.view.gestureRecognizers?.flatMap({ $0 as? KeyboardDismissTouchRecognizer }).first
    }
}








import UIKit
import UIKit.UIGestureRecognizerSubclass

open class KeyboardDismissTouchRecognizer: UIGestureRecognizer {
    open var callback: () -> Void
    open var ignoreViews: [UIView] = []
    open var canPreventOtherGestureRecognizers: Bool = true
    /// enable touches on view which is firstResponder
    open var ignoreFirstResponder: Bool = true
    
    public init(ignoreViews views: [UIView] = [], callback: @escaping () -> Void) {
        self.callback = callback
        self.ignoreViews = views
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(touchRecongized(_:)))
        observeKeyboarNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func observeKeyboarNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResign), name: .UIApplicationWillResignActive, object: nil)
    }
    
    @objc private func touchRecongized(_ sender: UIGestureRecognizer) {
        callback()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        if ignoreFirstResponder && touch.view?.canBecomeFirstResponder == true {
            print("Found a view that can become first responder", String(describing: touch.view!))
            self.state = .failed
            return
        }
        
        if ignoreViews.isEmpty && touch.view is UIControl {
            print("Found a view that is a UIButton or UIControl", String(describing: touch.view!))
            self.state = .failed
            return
        }
        
        for view in ignoreViews {
            if view.bounds.contains(touch.location(in: view)) {
                self.state = .failed
                return
            }
        }
        
        self.state = .recognized
    }
    
    open override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canPreventOtherGestureRecognizers
    }
    
    //MARK: - keyboard events
    @objc private func keyboardWillAppear(notification: Notification) {
        isEnabled = true
    }
    
    @objc private func keyboardWillDisappear(notification: Notification) {
        isEnabled = false
    }
    
    @objc private func applicationWillResign(notification: Notification) {
        self.view?.window?.endEditing(true)
    }
}
