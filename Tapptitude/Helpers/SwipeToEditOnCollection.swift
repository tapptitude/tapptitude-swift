//
//  SwipeToEditOnCollection.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 09/11/15.
//  Copyright © 2015 Tapptitude. All rights reserved.
//

import UIKit

public protocol SwipeToEditOnCollection : class {
    var panGestureRecognizer : PanViewGestureRecognizer? {get set}
    var tapGestureRecognizer : TouchRecognizer? {get set}
    
    var collectionView : UICollectionView! {get}
}

@objc public protocol SwipeToEditCell : class {
    var containerView : UIView! {get}
    var rightView : UIView! {get}
    
    func prepareForReuse() // override to reset transform
    
    func didTranslate(_ transform:CGAffineTransform, translationPercentInsets : UIEdgeInsets)
    
    func shouldStartSwipe() -> Bool
}


public extension SwipeToEditCell where Self: UICollectionViewCell {
    func shouldStartSwipe() -> Bool {
        return true
    }
    
    func prepareForReuse() {
        self.containerView.transform = CGAffineTransform.identity
    }
}


public extension SwipeToEditOnCollection {
    
    func addSwipeToEdit() {
        self.addPanGestureRecognizer()
        self.addDismissGestureRecognizer()
    }
    
    func addPanGestureRecognizer () {
        panGestureRecognizer = PanViewGestureRecognizer()
        panGestureRecognizer!.animationDuration = 0.33
        self.collectionView?.addGestureRecognizer(self.panGestureRecognizer!)
        
        self.panGestureRecognizer?.shouldBeginBlock = {[unowned self] (gesture : PanViewGestureRecognizer) -> Bool in
            let point = gesture.location(in: self.collectionView)
            guard let indexPath = self.collectionView?.indexPathForItem(at: point) else {
                return false
            }
            
            guard let editCell = self.collectionView?.cellForItem(at: indexPath) as? SwipeToEditCell else {
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
            self.registerAnimationsToEditCell(editCell)
            
//            let width = editCell.rightView.bounds.size.width
//            self.panGestureRecognizer?.targetTranslation = CGPoint(x: -width, y: 0)
//            self.panGestureRecognizer?.allowedTranslationEdgeInsets = UIEdgeInsetsMake(0, -width, 0, 0)
            
            return true
        }
    }
    
    func addDismissGestureRecognizer() {
        tapGestureRecognizer = TouchRecognizer(callback: {[unowned self] () -> Void in
            self.panGestureRecognizer?.resetTranslationAnimated(true)
            }, ignoreViews: nil)
        tapGestureRecognizer?.isEnabled = false
        tapGestureRecognizer?.canPreventOtherGestureRecognizers = false
        tapGestureRecognizer?.require(toFail: panGestureRecognizer!)
        
        collectionView?.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func registerAnimationsToEditCell(_ editCell : SwipeToEditCell?) {
        let gesture = self.panGestureRecognizer!
        
        gesture.targetPanView = editCell?.containerView
        let width = editCell?.rightView?.bounds.size.width
        gesture.tippingPercentageEdgeInsets = UIEdgeInsetsMake(0, 0.5, 0, 0.5)
        gesture.targetTranslation = CGPoint(x: -width!, y: 0)
        gesture.allowedTranslationEdgeInsets = UIEdgeInsetsMake(0, -width!, 0, 0)
        
        gesture.moveView = {(transform, translationPercentInsets) in
            editCell?.didTranslate(transform, translationPercentInsets: translationPercentInsets)
        }
        
        gesture.setResetTranslateAnimation({
                editCell?.didTranslate(.identity, translationPercentInsets: .zero)
            }, completion: {[weak self] _ in
                if let wself = self {
                    wself.tapGestureRecognizer?.isEnabled = wself.panGestureRecognizer?.isTranslated ?? false
                    editCell?.didTranslate(.identity, translationPercentInsets: .zero)
                }
        })

        let transform = CGAffineTransform(translationX: gesture.targetTranslation.x, y: gesture.targetTranslation.y)
        gesture.setTranslateAnimation({
                editCell?.didTranslate(transform, translationPercentInsets: UIEdgeInsetsMake(0, 1.0, 0, 0))
            }, completion: {[weak self] _ in
                if let wself = self {
                    wself.tapGestureRecognizer?.isEnabled = wself.panGestureRecognizer?.isTranslated ?? false
                    editCell?.didTranslate(transform, translationPercentInsets: UIEdgeInsetsMake(0, 1.0, 0, 0))
                }
        })
    }
}
