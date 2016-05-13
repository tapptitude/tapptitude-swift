//
//  SwipeToEditOnCollection.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 09/11/15.
//  Copyright © 2015 Tapptitude. All rights reserved.
//

import UIKit

public protocol SwipeToEditOnCollection : class {
    var panGestureRecognizer : SwipeToEditGesture? {get set}
    var tapGestureRecognizer : TouchRecognizer? {get set}
    
    var collectionView : UICollectionView? {get}
}

@objc public protocol SwipeToEditCell : class {
    var containerView : UIView! {get}
    var rightView : UIView! {get}
    
    func prepareForReuse() // override to reset transform
    
    func didTranslate(transform:CGAffineTransform, translationPercentInsets : UIEdgeInsets)
    
    func shouldStartSwipe() -> Bool
}


public extension SwipeToEditCell where Self: UICollectionViewCell {
    func shouldStartSwipe() -> Bool {
        return true
    }
    
    func prepareForReuse() {
        self.containerView.transform = CGAffineTransformIdentity
    }
}


public extension SwipeToEditOnCollection {
    
    func addSwipeToEdit() {
        self.addPanGestureRecognizer()
        self.addDismissGestureRecognizer()
    }
    
    func addPanGestureRecognizer () {
        panGestureRecognizer = SwipeToEditGesture()
        panGestureRecognizer!.animationDuration = 0.33
        self.collectionView?.addGestureRecognizer(self.panGestureRecognizer!)
        
        self.panGestureRecognizer?.shouldBeginBlock = {[unowned self] (gesture : SwipeToEditGesture) -> Bool in
            let point = gesture.locationInView(self.collectionView)
            guard let indexPath = self.collectionView?.indexPathForItemAtPoint(point) else {
                return false
            }
            
            guard let editCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? SwipeToEditCell else {
                return false
            }
            
            if !editCell.shouldStartSwipe() {
                return false
            }
            
            let isSameItem = (editCell.containerView === gesture.targetPanView);
            if (!isSameItem) {
                gesture.resetTranslationAnimated(true);
            }
            
            self.tapGestureRecognizer?.ignoreViews = [editCell.rightView]
            self.tapGestureRecognizer?.enabled = true
            self.registerAnimationsToEditCell(editCell)
            
            return true
        }
    }
    
    func addDismissGestureRecognizer() {
        tapGestureRecognizer = TouchRecognizer(callback: {[unowned self] () -> Void in
            self.panGestureRecognizer?.resetTranslationAnimated(true)
            }, ignoreViews: nil)
        tapGestureRecognizer?.enabled = false
        tapGestureRecognizer?.canPreventOtherGestureRecognizers = false
        tapGestureRecognizer?.requireGestureRecognizerToFail(panGestureRecognizer!)
        
        collectionView?.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func registerAnimationsToEditCell(editCell : SwipeToEditCell?) {
        let gesture = self.panGestureRecognizer!
        
        gesture.targetPanView = editCell?.containerView
        let width = editCell?.rightView?.bounds.size.width
        gesture.allowedTranslationEdgeInsets = UIEdgeInsetsMake(0, -width!, 0, 0)
        gesture.tippingPercentageEdgeInsets = UIEdgeInsetsMake(0, 0.5, 0, 0.5)
        gesture.targetTranslation = CGPointMake(-width!, 0)
        
        gesture.moveView = {(transform, translationPercentInsets) in
            editCell?.didTranslate(transform, translationPercentInsets: translationPercentInsets)
        }
        
        gesture.setResetTranslateAnimation({ _ in
                editCell?.didTranslate(CGAffineTransformIdentity, translationPercentInsets: UIEdgeInsetsZero)
            }, completion: {[unowned self] _ in
                self.tapGestureRecognizer?.enabled = self.panGestureRecognizer!.isTranslated
                editCell?.didTranslate(CGAffineTransformIdentity, translationPercentInsets: UIEdgeInsetsZero)
        })

        let transform = CGAffineTransformMakeTranslation(gesture.targetTranslation.x, gesture.targetTranslation.y)
        gesture.setTranslateAnimation({ _ in
                editCell?.didTranslate(transform, translationPercentInsets: UIEdgeInsetsMake(0, 1.0, 0, 0))
            }, completion: {[unowned self] _ in
                self.tapGestureRecognizer?.enabled = self.panGestureRecognizer!.isTranslated
                editCell?.didTranslate(transform, translationPercentInsets: UIEdgeInsetsMake(0, 1.0, 0, 0))
        })
    }
}



public class SwipeToEditGesture: PanViewGestureRecognizer {
    public var shouldBeginBlock : ((gesture: SwipeToEditGesture) -> Bool)?
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.shouldBeginBlock!(gesture: self)
        if (shouldBegin) {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        return false
    }
}
