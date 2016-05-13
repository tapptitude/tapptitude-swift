//
//  TouchRecognizer.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/14.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class TouchRecognizer: UIGestureRecognizer {
    public var callback: () -> Void
    public var ignoreViews: [UIView]?
    public var canPreventOtherGestureRecognizers: Bool = true
    public var ignoreFirstResponder: Bool = false // enable touches on view with keboard
    
    public init(callback: () -> Void, ignoreViews views: [UIView]?) {
        self.callback = callback
        self.ignoreViews = views
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(TouchRecognizer.touchRecongized(_:)))
    }
    
    override init(target: AnyObject?, action: Selector) {
        self.callback = {}
        super.init(target: target, action: action)
    }
    
    func touchRecongized(sender: UIGestureRecognizer) {
        callback()
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        let touch = touches.first!
        if ignoreFirstResponder && touch.view!.isFirstResponder() {
            return
        }
        
        for view in (ignoreViews ?? []) {
            if CGRectContainsPoint(view.bounds, touch.locationInView(view)) {
                self.state = .Failed
                return
            }
        }
        
        self.state = .Recognized
    }
    
    public override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canPreventOtherGestureRecognizers
    }
}