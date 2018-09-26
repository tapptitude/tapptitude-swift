//
//  DimmingBlurTransition.swift
//  Shebah
//
//  Created by Alexandru Tudose on 21/10/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

class DimmingBlurTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    struct Options {
        var dimmingColor: UIColor = UIColorFromRGB(0x000000).withAlphaComponent(0.4)
        var blur = false
        var blurRadius = 2.0
        var blurIteration: UInt = 8
        var blurTintColor: UIColor?
        var duration: TimeInterval = 0.3
        var shouldDismissOutsied: Bool = false
        
        var animation: Animation = .up
        var showAnimation: ((_ view: UIView, _ duration: TimeInterval, _ runAnimation: () -> (), _ completion:((Bool) -> Void)) -> ())?
        var dismissAnimation: ((_ view: UIView, _ duration: TimeInterval, _ runAnimation: () -> (), _ completion:((Bool) -> Void)) -> ())?
        
        mutating func setShowAnimation(_ animation: @escaping ((_ view: UIView, _ duration: TimeInterval, _ runAnimation: () -> (), _ completion:((Bool) -> Void)) -> ())) {
            showAnimation = animation
            self.animation = Animation.custom(showAnimation: showAnimation!, dismissAnimation: dismissAnimation)
        }
        
        mutating func setDismissAnimation(_ animation: @escaping ((_ view: UIView, _ duration: TimeInterval, _ runAnimation: () -> (), _ completion:((Bool) -> Void)) -> ())) {
            dismissAnimation = animation
            self.animation = Animation.custom(showAnimation: showAnimation, dismissAnimation: dismissAnimation)
        }
    }
    
    var options = Options()
    var isReverse = false
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isReverse = false
        return self
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isReverse = true
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return options.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let animationDuration = self.transitionDuration(using: transitionContext)
        let dimmingViewKey = "dimmingView"
        let blurViewKey = "blurView"
        
        if !isReverse {
            if options.blur {
                let image = fromViewController.view.captureImage()
                let blurredImage = image.blurredImage(withRadius: CGFloat(options.blurRadius), iterations: options.blurIteration)
                
                let blurView = UIImageView(image: blurredImage)
                fromViewController.view.addSubview(blurView)
                fromViewController.view.layer.setValue(blurView, forKey: blurViewKey)
                
                blurView.alpha = 0.0
                UIView.animate(withDuration: animationDuration, animations: {
                    blurView.alpha = 1.0
                })
            }
            
            let dimmingView = UIView()
            dimmingView.backgroundColor = UIColor.clear
            dimmingView.frame = fromViewController.view.bounds
            fromViewController.view.addSubview(dimmingView)
            fromViewController.view.layer.setValue(dimmingView, forKey: dimmingViewKey)
            
            containerView.addSubview(toViewController.view)
            
            options.animation.animate(true, duration: animationDuration, view: toViewController.view, runAnimation: {
                dimmingView.backgroundColor = self.options.dimmingColor
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
            
        } else {
            let dimmingView = toViewController.view.layer.value(forKey: dimmingViewKey) as! UIView
            let blurView = toViewController.view.layer.value(forKey: blurViewKey) as? UIView
            
            options.animation.animate(false, duration: animationDuration, view: fromViewController.view, runAnimation: {
                dimmingView.backgroundColor = UIColor.clear
                blurView?.alpha = 0.0
                }, completion: { finished in
                    fromViewController.view.removeFromSuperview()
                    dimmingView.removeFromSuperview()
                    blurView?.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    
    enum Animation {
        case fade
        case up
        case custom(showAnimation: ((_ view: UIView, _ duration: TimeInterval, _ runAnimation: @escaping () -> (), _ completion: @escaping((Bool) -> Void)) -> ())?,
            dismissAnimation: ((_ view: UIView, _ duration: TimeInterval, _ runAnimation:  @escaping () -> (), _ completion: @escaping ((Bool) -> Void)) -> ())?)
        
    
        func animate(_ show: Bool, duration: TimeInterval, view: UIView, runAnimation: @escaping () -> (), completion:@escaping ((Bool) -> Void)) -> () {
            switch self {
            case .fade:
                fadeAnimation(show, duration: duration, view: view, runAnimation: runAnimation, completion: completion)
            case .up:
                upAnimation(show, duration: duration, view: view, runAnimation: runAnimation, completion: completion)
            case .custom(let showAnimation, let dismissAnimation):
                if show {
                    if let showAnimation = showAnimation {
                        showAnimation(view, duration, runAnimation, completion)
                    } else {
                        fadeAnimation(show, duration: duration, view: view, runAnimation: runAnimation, completion: completion)
                    }
                } else {
                    if let dismissAnimation = dismissAnimation {
                        dismissAnimation(view, duration, runAnimation, completion)
                    } else {
                        fadeAnimation(show, duration: duration, view: view, runAnimation: runAnimation, completion: completion)
                    }
                }
            }
        }
        
        func fadeAnimation(_ show: Bool, duration: TimeInterval, view: UIView, runAnimation: @escaping () -> (), completion:@escaping ((Bool) -> Void)) {
            if show {
                view.alpha = 0.0
                UIView.animate(withDuration: duration, animations: {
                    view.alpha = 1.0
                    runAnimation()
                    }, completion: completion)
            } else {
                UIView.animate(withDuration: duration, animations: {
                    view.alpha = 0.0
                    runAnimation()
                    }, completion: completion)
            }
        }
        
        func upAnimation(_ show: Bool, duration: TimeInterval, view: UIView, runAnimation: @escaping () -> (), completion:@escaping ((Bool) -> Void)) {
            if show {
                view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
                    () -> Void in
                    runAnimation()
                    view.transform = CGAffineTransform.identity
                }, completion: completion)
  
            } else {
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    view.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                    runAnimation()
                    }, completion: completion)
            }
        }
    }
}
