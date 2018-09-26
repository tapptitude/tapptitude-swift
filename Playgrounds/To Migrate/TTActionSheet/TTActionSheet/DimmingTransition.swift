//
//  DimmingTransition.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 24/06/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
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

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView

        let animationDuration = self.transitionDuration(using: transitionContext)
		let dimmingViewKey = "dimmingView"

		if !isReverse {
			let dimmingView = UIView()
            dimmingView.backgroundColor = UIColor.clear
			dimmingView.frame = fromViewController.view.bounds
			fromViewController.view.addSubview(dimmingView)
			fromViewController.view.layer.setValue(dimmingView, forKey: dimmingViewKey)

            toViewController.view.transform = CGAffineTransform(translationX: 0, y: toViewController.view.frame.height)
            containerView.addSubview(toViewController.view)

            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut,
                           animations: { dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
					toViewController.view.transform = CGAffineTransform.identity
				},
				completion: { (finished) -> Void in
					transitionContext.completeTransition(finished) })
		} else {
            let dimmingView = toViewController.view.layer.value(forKey: dimmingViewKey) as! UIView

            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut,
				animations: { () -> Void in
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: fromViewController.view.frame.height)
                    dimmingView.backgroundColor = UIColor.clear
				},
				completion: { (finished) -> Void in
					fromViewController.view.removeFromSuperview()
					dimmingView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})

		}
	}
}
