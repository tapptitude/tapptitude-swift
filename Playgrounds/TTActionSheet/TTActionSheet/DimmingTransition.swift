//
//  DimmingTransition.swift
//  Winmasters
//
//  Created by Alexandru Tudose on 24/06/16.
//  Copyright © 2016 Winmasters. All rights reserved.
//

import UIKit

class DimmingTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
	var isReverse = false

	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isReverse = false
		return self
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isReverse = true
		return self
	}

	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.35
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let containerView = transitionContext.containerView()

		let animationDuration = self.transitionDuration(transitionContext)
		let dimmingViewKey = "dimmingView"

		if !isReverse {
			let dimmingView = UIView()
			dimmingView.backgroundColor = UIColor.clearColor()
			dimmingView.frame = fromViewController.view.bounds
			fromViewController.view.addSubview(dimmingView)
			fromViewController.view.layer.setValue(dimmingView, forKey: dimmingViewKey)

			toViewController.view.transform = CGAffineTransformMakeTranslation(0, toViewController.view.frame.height)
			containerView!.addSubview(toViewController.view)

			UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseInOut,
				animations: { dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
					toViewController.view.transform = CGAffineTransformIdentity
				},
				completion: { (finished) -> Void in
					transitionContext.completeTransition(finished) })
		} else {
			let dimmingView = toViewController.view.layer.valueForKey(dimmingViewKey) as! UIView

			UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut,
				animations: { () -> Void in
					fromViewController.view.transform = CGAffineTransformMakeTranslation(0, fromViewController.view.frame.height)
					dimmingView.backgroundColor = UIColor.clearColor()
				},
				completion: { (finished) -> Void in
					fromViewController.view.removeFromSuperview()
					dimmingView.removeFromSuperview()
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})

		}
	}
}