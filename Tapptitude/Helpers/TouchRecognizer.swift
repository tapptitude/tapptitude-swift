//
//  TouchRecognizer.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/14.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchRecognizer: UIGestureRecognizer {
    var callback: () -> Void
    var ignoreViews: [UIView]?
    var canPreventOtherGestureRecognizers: Bool = true
    var ignoreFirstResponder: Bool = false // enable touches on view with keboard
    
    init(callback: () -> Void, ignoreViews views: [UIView]?) {
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
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
    
    override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canPreventOtherGestureRecognizers
    }
}