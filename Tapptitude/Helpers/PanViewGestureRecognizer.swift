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

class PanViewGestureRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    var animationDuration: NSTimeInterval = 0.55
    
    var targetTranslation: CGPoint!
    var allowedTranslationEdgeInsets: UIEdgeInsets! { // relative from identity transform
        didSet {
            //    assert(allowedTranslationEdgeInsets.left <= 0.0, "left inset should <= 0.0");
            //    assert(allowedTranslationEdgeInsets.right >= 0.0, "right inset should >= 0.0");
            //    assert(allowedTranslationEdgeInsets.top <= 0.0, "top inset should <= 0.0");
            //    assert(allowedTranslationEdgeInsets.bottom >= 0.0, "bottom inset should >= 0.0");
        }
    }
    var tippingPercentageEdgeInsets: UIEdgeInsets = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5) { // the percentage point (from allowedTranslationEdgeInsets) when it should switch to next state
        didSet {
            assert(tippingPercentageEdgeInsets.top >= 0.0 || tippingPercentageEdgeInsets.top <= 1.0, "0.0 >= top inset <= 1.0");
            assert(tippingPercentageEdgeInsets.left >= 0.0 || tippingPercentageEdgeInsets.left <= 1.0, "0.0 >= left inset <= 1.0");
            assert(tippingPercentageEdgeInsets.bottom >= 0.0 || tippingPercentageEdgeInsets.bottom <= 1.0, "0.0 >= bottom inset <= 1.0");
            assert(tippingPercentageEdgeInsets.right >= 0.0 || tippingPercentageEdgeInsets.right <= 1.0, "0.0 >= right inset <= 1.0");
        }
    }
    
    var translateAnimation: (() -> ())? // will run inside an animation block, view will be translated with targetTranslation
    var resetTranslationAnimation: (() -> ())? //                                    view will be translated to 0
    var moveView: ((transform: CGAffineTransform, translationPercentInsets: UIEdgeInsets) -> ())?
    
    var translateCompletion: ((canceled: Bool) -> ())?
    var resetTranslationCompletion: ((canceled: Bool) -> ())?
    
    var willEndPaning: ((canceled: Bool) -> ())? // was cancelled or not, you can change the targetTranslation
    
    init () {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(PanViewGestureRecognizer.moveView(_:)))
        self.delegate = self
    }
    
    weak var targetPanView: UIView?
    
    var _targetPanView: UIView? {
        return self.targetPanView ?? self.view
    }
    
    func translateAnimated(animated: Bool) {
        let areAnimationsEnabled = UIView.areAnimationsEnabled()
        if !animated {
            UIView.setAnimationsEnabled(false)
        }
        
        translateWithDuration(animationDuration, options:.CurveEaseInOut)
        
        if !animated {
            UIView.setAnimationsEnabled(areAnimationsEnabled)
        }
    }
    
    func resetTranslationAnimated(animated: Bool) {
        let areAnimationsEnabled = UIView.areAnimationsEnabled()
        if !animated {
            UIView.setAnimationsEnabled(false)
        }
        
        resetTranslationWithDuration(animationDuration, options:.CurveEaseInOut)
    
        if !animated {
            UIView.setAnimationsEnabled(areAnimationsEnabled)
        }
    }
    
    var isTranslated: Bool {
        let targetPanView = self.targetPanView!
        return targetPanView.transform.tx != 0.0 || targetPanView.transform.ty != 0.0
    }
    
    func toggleTranslatedState() {
        if isTranslated {
            resetTranslationAnimated(true)
        } else {
            translateAnimated(true)
        }
    }
    
    func setTranslateAnimation(translateAnimation: () -> (), completion:(finished: Bool) -> ()) {
        self.translateAnimation = translateAnimation;
        self.translateCompletion = completion;
    }
    
    func setResetTranslateAnimation(resetAnimation: () -> (), completion:(finished: Bool) -> ()) {
        self.resetTranslationAnimation = resetAnimation;
        self.resetTranslationCompletion = completion;
    }
    
    //MARK - Animations
    
    func translateWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions) {
        let translateAnimation = self.translateAnimation
        let translateCompletion = self.translateCompletion
    
        UIView.animateWithDuration(duration, delay: 0, options: [options, .BeginFromCurrentState], animations: { 
            self.targetPanView?.transform = CGAffineTransformMakeTranslation(self.targetTranslation.x, self.targetTranslation.y)
            translateAnimation?();
            }) { (finished) in
            translateCompletion?(canceled: finished)
        }
    }
    
    func resetTranslationWithDuration(duration: NSTimeInterval, options: UIViewAnimationOptions) {
        let resetTranslationAnimation = self.resetTranslationAnimation
        let resetTranslationCompletion = self.resetTranslationCompletion
        
        UIView.animateWithDuration(duration, delay: 0, options: [options, .BeginFromCurrentState], animations: {
            self.targetPanView?.transform = CGAffineTransformIdentity
            resetTranslationAnimation?();
        }) { (finished) in
            resetTranslationCompletion?(canceled: finished)
        }
    }
    
    func translateWithVelocity(velocityPoint: CGPoint) {
        let transform = self.targetPanView!.transform
        let xDirection = transform.tx != 0.0
        
        let targetTranslation = self.targetTranslation
        
        let remPixels = fabs(xDirection ? targetTranslation.x : targetTranslation.y) - fabs(xDirection ? transform.tx : transform.ty)
        let velocity = xDirection ? velocityPoint.x : velocityPoint.y
        
        let duration = min(NSTimeInterval(fabs(remPixels / velocity)), animationDuration)
        translateWithDuration(duration, options:.CurveEaseInOut)
    }
    
    func resetTranslationWithVelocity(velocityPoint: CGPoint) {
        let transform = self.targetPanView!.transform
        let xDirection = transform.tx != 0.0
        let remPixels: CGFloat = fabs(xDirection ? transform.tx : transform.ty)
        let velocity = xDirection ? velocityPoint.x : velocityPoint.y
        
        let duration = min(NSTimeInterval(fabs(remPixels / velocity)), animationDuration)
        resetTranslationWithDuration(duration, options:.CurveEaseInOut)
    }
    
    //MARK: - Gestures
    private var lastMoveTime: NSTimeInterval = 0.0
    
    func moveView(panRecognizer: UIPanGestureRecognizer) {
        let targetPanView = self.targetPanView!
        
        let translation = panRecognizer.translationInView(self.view)
        
        if panRecognizer.state == .Changed || panRecognizer.state == .Possible {
            var transform = targetPanView.transform
            transform.ty += translation.y
            transform.tx += translation.x
            
            let insets = self.allowedTranslationEdgeInsets
            
            transform.tx = max(transform.tx, insets.left);
            transform.tx = min(transform.tx, insets.right);
            transform.ty = max(transform.ty, insets.top);
            transform.ty = min(transform.ty, insets.bottom);
            
            targetPanView.transform = transform;
            
            if let moveView = self.moveView {
                let translationPercentInsets = UIEdgeInsetsMake(insets.top != 0.0 ? (transform.ty / insets.top) : 0.0,
                insets.left != 0.0 ? (transform.tx / insets.left) : 0.0,
                insets.bottom != 0.0 ? (transform.ty / insets.bottom) : 0.0,
                insets.right != 0.0 ? (transform.tx / insets.right) : 0.0);
                moveView(transform: transform, translationPercentInsets: translationPercentInsets)
            }
            
            lastMoveTime = NSDate.timeIntervalSinceReferenceDate()
        }
        
        if panRecognizer.state == .Recognized {
            // user swipes fast then stops for period and lift his finger, we need to take this into account
            var velocity = CGPointZero
            let seconds = NSDate.timeIntervalSinceReferenceDate() - lastMoveTime
            if seconds < 0.4 {
                velocity = panRecognizer.velocityInView(targetPanView)
            }
        
            let transform = targetPanView.transform
            let insets = self.allowedTranslationEdgeInsets
            
            var passedTippingPoint = false
            let tippingPercentageInsets = self.tippingPercentageEdgeInsets
            if (tippingPercentageInsets.top != 0.0 && transform.ty < 0.0) {
                passedTippingPoint = (transform.ty + velocity.y) < (insets.top * tippingPercentageInsets.top);
            } else if (tippingPercentageInsets.left != 0.0  && transform.tx < 0.0) {
                passedTippingPoint = (transform.tx + velocity.x) < (insets.left * tippingPercentageInsets.left);
            } else if (tippingPercentageInsets.bottom != 0.0 && transform.ty > 0.0) {
                passedTippingPoint = (transform.ty + velocity.y) > (insets.bottom * tippingPercentageInsets.bottom);
            } else if (tippingPercentageInsets.right != 0.0 && transform.tx > 0.0) {
                passedTippingPoint = (transform.tx + velocity.x) > (insets.right * tippingPercentageInsets.right);
            }
        
            self.willEndPaning?(canceled: !passedTippingPoint)
            
            if passedTippingPoint {
                translateWithVelocity(velocity)
            } else {
                resetTranslationWithVelocity(velocity)
            }
        }
        
        if (panRecognizer.state == .Cancelled) {
            self.willEndPaning?(canceled: true)
        
            let velocity = panRecognizer.velocityInView(targetPanView)
            resetTranslationWithVelocity(velocity)
        }
        
        panRecognizer.setTranslation(CGPointZero, inView:self.view)
    }
    
    func gestureRecognizerShouldBegin(recognizer: UIGestureRecognizer) -> Bool {
        let panRecognizer = recognizer as! UIPanGestureRecognizer
        let velocity = panRecognizer.velocityInView(self.targetPanView)
        if ((self.tippingPercentageEdgeInsets.left != 0.0 || self.tippingPercentageEdgeInsets.right != 0.0)
        && (self.tippingPercentageEdgeInsets.top != 0.0 || self.tippingPercentageEdgeInsets.bottom != 0.0)) {
        return true;
        } else if (self.tippingPercentageEdgeInsets.left != 0.0 || self.tippingPercentageEdgeInsets.right != 0.0) {
        return abs(velocity.x) > abs(velocity.y); // Horizontal panning
        } else if (self.tippingPercentageEdgeInsets.top != 0.0 || self.tippingPercentageEdgeInsets.bottom != 0.0) {
        return abs(velocity.x) < abs(velocity.y); // Vertical panning
        }
        
        return false;
    }
    
    //- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    //}
}