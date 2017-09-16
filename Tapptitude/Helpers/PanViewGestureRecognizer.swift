//
//  PanViewGestureRecognizer.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 27/04/14.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

// Example

//    self.panGestureRecognizer = [[TTPanViewGestureRecognizer alloc] init];
//    self.panGestureRecognizer.targetPanView = self.photoView;
//
//    @weakify(self);
//    self.panGestureRecognizer.moveViewBlock = ^(CGAffineTransform transform, UIEdgeInsets translationPercentInsets){
//        @strongify(self);
//        self.cameraButton.alpha = (1 - translationPercentInsets.top) / 0.5f;
//    };
//
//    [self.panGestureRecognizer setTranslateAnimationBlock:^{
//        @strongify(self);
//        self.cameraButton.alpha = 0.0f;
//    } completionBlock:^(BOOL finished) {
//        @strongify(self);
//        [self.pictureController startCaptureSession];
//    }];
//
//    [self.panGestureRecognizer setResetTranslationAnimationBlock:^{
//        @strongify(self);
//        self.cameraButton.alpha = 1.0f;
//        [self.cameraButton.superview bringSubviewToFront:self.cameraButton];
//    } completionBlock:^(BOOL finished) {
//        @strongify(self);
//        [self.pictureController stopCaptureSession];
//    }];
//
//    self.panGestureRecognizer.allowedTranslationEdgeInsets = UIEdgeInsetsMake(-(self.view.frame.size.height - self.cameraButton.frame.size.height), 0, 0, 0);
//    self.panGestureRecognizer.tippingPercentageEdgeInsets = UIEdgeInsetsMake(0.5f, 0, 0.5f, 0);
//    self.panGestureRecognizer.targetTranslation = CGPointMake(0, -(self.view.frame.size.height - self.cameraButton.frame.size.height));

open class PanViewGestureRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    open var animationDuration: TimeInterval = 0.55
    
    open var targetTranslation: CGPoint!
    open var allowedTranslationEdgeInsets: UIEdgeInsets! { // relative from identity transform
        didSet {
            //    assert(allowedTranslationEdgeInsets.left <= 0.0, "left inset should <= 0.0");
            //    assert(allowedTranslationEdgeInsets.right >= 0.0, "right inset should >= 0.0");
            //    assert(allowedTranslationEdgeInsets.top <= 0.0, "top inset should <= 0.0");
            //    assert(allowedTranslationEdgeInsets.bottom >= 0.0, "bottom inset should >= 0.0");
        }
    }
    open var tippingPercentageEdgeInsets: UIEdgeInsets = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5) { // the percentage point (from allowedTranslationEdgeInsets) when it should switch to next state
        didSet {
            assert(tippingPercentageEdgeInsets.top >= 0.0 || tippingPercentageEdgeInsets.top <= 1.0, "0.0 >= top inset <= 1.0");
            assert(tippingPercentageEdgeInsets.left >= 0.0 || tippingPercentageEdgeInsets.left <= 1.0, "0.0 >= left inset <= 1.0");
            assert(tippingPercentageEdgeInsets.bottom >= 0.0 || tippingPercentageEdgeInsets.bottom <= 1.0, "0.0 >= bottom inset <= 1.0");
            assert(tippingPercentageEdgeInsets.right >= 0.0 || tippingPercentageEdgeInsets.right <= 1.0, "0.0 >= right inset <= 1.0");
        }
    }
    
    open var translateAnimation: (() -> ())? // will run inside an animation block, view will be translated with targetTranslation
    open var resetTranslationAnimation: (() -> ())? //                                    view will be translated to 0
    open var moveView: ((_ transform: CGAffineTransform, _ translationPercentInsets: UIEdgeInsets) -> ())?
    
    open var translateCompletion: ((_ canceled: Bool) -> ())?
    open var resetTranslationCompletion: ((_ canceled: Bool) -> ())?
    
    open var willEndPaning: ((_ canceled: Bool) -> ())? // was cancelled or not, you can change the targetTranslation
    
    open weak var targetPanView: UIView?
    
    open var shouldBeginBlock : ((_ gesture: PanViewGestureRecognizer) -> Bool)?
    
    var _targetPanView: UIView? {
        return self.targetPanView ?? self.view
    }
    
    public init () {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(PanViewGestureRecognizer.moveView(_:)))
        self.delegate = self
    }
    
    
    open func translateAnimated(_ animated: Bool) {
        let areAnimationsEnabled = UIView.areAnimationsEnabled
        if !animated {
            UIView.setAnimationsEnabled(false)
        }
        
        translateWithDuration(animationDuration, options:UIViewAnimationOptions())
        
        if !animated {
            UIView.setAnimationsEnabled(areAnimationsEnabled)
        }
    }
    
    open func resetTranslationAnimated(_ animated: Bool) {
        let areAnimationsEnabled = UIView.areAnimationsEnabled
        if !animated {
            UIView.setAnimationsEnabled(false)
        }
        
        resetTranslationWithDuration(animationDuration, options:UIViewAnimationOptions())
    
        if !animated {
            UIView.setAnimationsEnabled(areAnimationsEnabled)
        }
    }
    
    open var isTranslated: Bool {
        if let transform = self.targetPanView?.transform {
            return transform.tx != 0.0 || transform.ty != 0.0
        } else {
            return false
        }
    }
    
    public func toggleTranslatedState() {
        if isTranslated {
            resetTranslationAnimated(true)
        } else {
            translateAnimated(true)
        }
    }
    
    public func setTranslateAnimation(_ translateAnimation: @escaping () -> (), completion:@escaping (_ finished: Bool) -> ()) {
        self.translateAnimation = translateAnimation
        self.translateCompletion = completion
    }
    
    public func setResetTranslateAnimation(_ resetAnimation: @escaping () -> (), completion:@escaping (_ finished: Bool) -> ()) {
        self.resetTranslationAnimation = resetAnimation
        self.resetTranslationCompletion = completion
    }
    
    //MARK - Animations
    
    func translateWithDuration(_ duration: TimeInterval, options: UIViewAnimationOptions) {
        let translateAnimation = self.translateAnimation
        let translateCompletion = self.translateCompletion
    
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState], animations: { 
            self.targetPanView?.transform = CGAffineTransform(translationX: self.targetTranslation.x, y: self.targetTranslation.y)
            translateAnimation?()
            }) { (finished) in
            translateCompletion?(finished)
        }
    }
    
    func resetTranslationWithDuration(_ duration: TimeInterval, options: UIViewAnimationOptions) {
        let resetTranslationAnimation = self.resetTranslationAnimation
        let resetTranslationCompletion = self.resetTranslationCompletion
        
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState], animations: {
            self.targetPanView?.transform = CGAffineTransform.identity
            resetTranslationAnimation?()
        }) { (finished) in
            resetTranslationCompletion?(finished)
        }
    }
    
    func translateWithVelocity(_ velocityPoint: CGPoint) {
        let transform = self.targetPanView!.transform
        let xDirection = transform.tx != 0.0
        
        let targetTranslation = self.targetTranslation
        
        let remPixels = fabs((xDirection ? targetTranslation?.x : targetTranslation?.y)!) - fabs(xDirection ? transform.tx : transform.ty)
        let velocity = xDirection ? velocityPoint.x : velocityPoint.y
        
        let duration = min(TimeInterval(fabs(remPixels / velocity)), animationDuration)
        translateWithDuration(duration, options:UIViewAnimationOptions())
    }
    
    func resetTranslationWithVelocity(_ velocityPoint: CGPoint) {
        let transform = self.targetPanView!.transform
        let xDirection = transform.tx != 0.0
        let remPixels: CGFloat = fabs(xDirection ? transform.tx : transform.ty)
        let velocity = xDirection ? velocityPoint.x : velocityPoint.y
        
        let duration = min(TimeInterval(fabs(remPixels / velocity)), animationDuration)
        resetTranslationWithDuration(duration, options:UIViewAnimationOptions())
    }
    
    //MARK: - Gestures
    fileprivate var lastMoveTime: TimeInterval = 0.0
    
    @objc func moveView(_ panRecognizer: UIPanGestureRecognizer) {
        let targetPanView = self.targetPanView!
        
        let translation = panRecognizer.translation(in: self.view)
        
        if panRecognizer.state == .changed || panRecognizer.state == .possible {
            var transform = targetPanView.transform
            transform.ty += translation.y
            transform.tx += translation.x
            
            let insets = self.allowedTranslationEdgeInsets!
            
            transform.tx = max(transform.tx, insets.left)
            transform.tx = min(transform.tx, insets.right)
            transform.ty = max(transform.ty, insets.top)
            transform.ty = min(transform.ty, insets.bottom)
            
            targetPanView.transform = transform;
            
            if let moveView = self.moveView {
                let translationPercentInsets = UIEdgeInsetsMake(insets.top != 0.0 ? (transform.ty / insets.top) : 0.0,
                insets.left != 0.0 ? (transform.tx / insets.left) : 0.0,
                insets.bottom != 0.0 ? (transform.ty / insets.bottom) : 0.0,
                insets.right != 0.0 ? (transform.tx / insets.right) : 0.0)
                moveView(transform, translationPercentInsets)
            }
            
            lastMoveTime = Date.timeIntervalSinceReferenceDate
        }
        
        if panRecognizer.state == .recognized {
            // user swipes fast then stops for period and lift his finger, we need to take this into account
            var velocity = CGPoint.zero
            let seconds = Date.timeIntervalSinceReferenceDate - lastMoveTime
            if seconds < 0.4 {
                velocity = panRecognizer.velocity(in: targetPanView)
            }
        
            let transform = targetPanView.transform
            let insets = self.allowedTranslationEdgeInsets!
            
            var passedTippingPoint = false
            let tippingPercentageInsets = self.tippingPercentageEdgeInsets
            if (tippingPercentageInsets.top != 0.0 && transform.ty < 0.0) {
                passedTippingPoint = (transform.ty + velocity.y) < (insets.top * tippingPercentageInsets.top)
            } else if (tippingPercentageInsets.left != 0.0  && transform.tx < 0.0) {
                passedTippingPoint = (transform.tx + velocity.x) < (insets.left * tippingPercentageInsets.left)
            } else if (tippingPercentageInsets.bottom != 0.0 && transform.ty > 0.0) {
                passedTippingPoint = (transform.ty + velocity.y) > (insets.bottom * tippingPercentageInsets.bottom)
            } else if (tippingPercentageInsets.right != 0.0 && transform.tx > 0.0) {
                passedTippingPoint = (transform.tx + velocity.x) > (insets.right * tippingPercentageInsets.right)
            }
        
            self.willEndPaning?(!passedTippingPoint)
            
            if passedTippingPoint {
                translateWithVelocity(velocity)
            } else {
                resetTranslationWithVelocity(velocity)
            }
        }
        
        if panRecognizer.state == .cancelled {
            self.willEndPaning?(true)
        
            let velocity = panRecognizer.velocity(in: targetPanView)
            resetTranslationWithVelocity(velocity)
        }
        
        panRecognizer.setTranslation(CGPoint.zero, in:self.view)
    }
    
    open func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
        if let shouldBeginBlock = self.shouldBeginBlock {
            let shouldBegin = shouldBeginBlock(self)
            if !shouldBegin {
                return false
            }
        }
        
        let panRecognizer = recognizer as! UIPanGestureRecognizer
        let velocity = panRecognizer.velocity(in: self.targetPanView)
        if ((self.tippingPercentageEdgeInsets.left != 0.0 || self.tippingPercentageEdgeInsets.right != 0.0)
        && (self.tippingPercentageEdgeInsets.top != 0.0 || self.tippingPercentageEdgeInsets.bottom != 0.0)) {
            return true
        } else if (self.tippingPercentageEdgeInsets.left != 0.0 || self.tippingPercentageEdgeInsets.right != 0.0) {
            return abs(velocity.x) > abs(velocity.y) // Horizontal panning
        } else if (self.tippingPercentageEdgeInsets.top != 0.0 || self.tippingPercentageEdgeInsets.bottom != 0.0) {
            return abs(velocity.x) < abs(velocity.y) // Vertical panning
        }
        
        return false
    }
}
