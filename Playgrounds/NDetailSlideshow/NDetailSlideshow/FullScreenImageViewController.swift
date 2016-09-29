//
//  FullScreenImageViewController.swift
//  Bildnytt
//
//  Created by Ion Toderasco on 01/08/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude


extension UIView {
    func captureImageByTakingScaleIntoAccount() -> UIImage {
        let size = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0); //- grab the image using current screen scale
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

func CGSizeAspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
    var boundingSize = boundingSize
    let mW = boundingSize.width / aspectRatio.width
    let mH = boundingSize.height / aspectRatio.height
    
    if mH < mW {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
    } else if mW < mH {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
    }
    return boundingSize
}

func CGRectWithAspectRatioInsideRect(aspectRatio: CGSize, boundingRect: CGRect) -> CGRect {
    let boundingSize = boundingRect.size
    let aspectSize = CGSizeAspectFit(aspectRatio, boundingSize: boundingSize)
    let rect = CGRectMake(boundingRect.origin.x + (boundingSize.width - aspectSize.width) * 0.5,
                             boundingRect.origin.y + (boundingSize.height - aspectSize.height) * 0.5,
                             aspectSize.width, aspectSize.height)
    return rect
}

protocol ImagesFullScreenViewControllerDelegate: class {
    
    func imagesFullScreenViewController(controller: FullScreenImageViewController, prepareForDismissingWithIndexPath indexPath: NSIndexPath)
    func imagesFullScreenViewController(controller: FullScreenImageViewController, viewForIndexPath indexPath: NSIndexPath) -> UIView?
    func imagesFullScreenViewController(controller: FullScreenImageViewController, frameForIndexPath indexPath: NSIndexPath) -> CGRect?
}

public class FullScreenImageViewController: CollectionFeedController, UIGestureRecognizerDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var animatedImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var liftedImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    weak var delegate: ImagesFullScreenViewControllerDelegate!

    var displayedIndex: Int?
    var indexPath: NSIndexPath?
    
    var willHide = false
    var panGestureRecognizer: UIPanGestureRecognizer?
    var doubleTapRecognizer: UITapGestureRecognizer?
    var rotatingCell: ImagesFullScreenCell?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //initWithContent
    init(content: [AnyObject], displayIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        configureForContent(content, displayIndex: displayIndex)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureForContent(content: [AnyObject], displayIndex: Int) {
        self.modalTransitionStyle = .CrossDissolve
        self.modalPresentationCapturesStatusBarAppearance = true
        self.modalPresentationStyle = .Custom

        let cellController = ImagesFullScreenCellController()
        self.displayedIndex = displayIndex
        self.cellController = cellController
        self.dataSource = DataSource(content)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.frame = UIScreen.mainScreen().bounds
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panAction))
        self.panGestureRecognizer?.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer!)
        
        self.doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction))
        self.doubleTapRecognizer?.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(self.doubleTapRecognizer!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeAction(_:)))
        tapGestureRecognizer.requireGestureRecognizerToFail(self.doubleTapRecognizer!)
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.collectionView?.frame = CGRectMake(-10, 0, self.view.frame.size.width + 20.0, self.view.frame.size.height)
        self.willHide = true
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.orientationChangedNotification), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        if self.displayedIndex != NSNotFound, let index = displayedIndex {
            self.collectionView?.layoutSubviews()
            self.collectionView?.contentOffset = CGPointMake(CGFloat(index) * self.collectionView!.frame.size.width, 0)
            self.indexPath = NSIndexPath(forItem: index, inSection: 0)
        }
        
        self.animateViewAppearWithMove()
    }
    
    func animateViewAppearWithMove() {
        let image = self.liftedImageView.image
        self.animatedImageView.image = image
        print(self.animatedImageView.image?.size)
        var imageSize: CGSize = image?.size ?? self.animatedImageView.bounds.size
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(self.animatedImageView)
        
        self.animatedImageView.frame = self.liftedImageView.convertRect(self.liftedImageView.bounds, toView: window)
        self.animatedImageView.contentMode = self.liftedImageView.contentMode
        print(self.animatedImageView.contentMode)
        
        self.rotateViewToMatchInterfaceOrientation()
        
        self.closeButton.alpha = 0.0
        self.view.userInteractionEnabled = false
        self.collectionView?.hidden = true
        UIView.animateWithDuration(0.4, animations: {
            let orientation = UIDevice.currentDevice().orientation
            
            if orientation == .LandscapeLeft {
                self.animatedImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            } else if orientation == .LandscapeRight {
                self.animatedImageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            } else {
                self.animatedImageView.transform = CGAffineTransformIdentity
            }
            
            if UIDeviceOrientationIsLandscape(orientation) {
                imageSize = CGSizeMake(imageSize.height, imageSize.width)
            }
            
            self.animatedImageView.frame = CGRectWithAspectRatioInsideRect(imageSize, boundingRect: window!.bounds)
            self.closeButton.alpha = 1.0
        }) { finished in
            self.view.userInteractionEnabled = true
            self.willHide = false
            self.setNeedsStatusBarAppearanceUpdate()
            
            self.animatedImageView.hidden = true
            self.view.addSubview(self.animatedImageView)
            self.collectionView?.hidden = false
        }
    }

    override public func prefersStatusBarHidden() -> Bool {
        return !self.willHide
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override public func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    
    //MARK: - Actions
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let touchPoint = touch.locationInView(self.view)
        
        if closeButton.pointInside(touchPoint, withEvent: nil) {
            self.closeAction(self)
        }
        
        return true
    }
    
    func doubleTapAction(recognizer: UITapGestureRecognizer) {
        if let indexPath = self.indexPath {
            if let currentCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? ImagesFullScreenCell {
                currentCell.toggleZoomAtPoint(recognizer.locationInView(currentCell))
            }
        }
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.animatedImageView.hidden = false
        self.collectionView?.hidden = true
        
        self.prepareUIForDissmissAndUpdateAnimatedViewFrame(true)
        self.hideImageAnimated(true)
    }
    
    @IBAction func panAction(sender: AnyObject) {
        self.updateCurrentTitle(false)
        self.closeButton.hidden = true
        self.animatedImageView.hidden = false
        self.collectionView?.hidden = true
        
        let translation = self.panGestureRecognizer?.translationInView(self.view)
        let ration = 1.0 / self.view.center.y
        
        self.overlayView.alpha = translation!.y == 0.0 ? 1.0 : 1.0 - ration * abs(translation!.y)
        self.animatedImageView.center = CGPointMake(self.view.center.x, self.view.center.y + translation!.y)
        
        if self.panGestureRecognizer?.state == .Ended {
            self.completeTranslationForceHide(false)
        }
    }
    
    func tapAction(gesture: UITapGestureRecognizer) {
        self.hideImageAnimated(true)
    }
    
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            self.updateCurrentTitle(false)
            
            let allImg = Int(ceil(scrollView.contentSize.width / self.view.frame.width)) - 1
            var current = Int(ceil(scrollView.contentOffset.x / self.view.frame.width))
            current = current == 0 ? 1 : current
            let number = "\(current) / \(allImg)"
            }
    }
    
    
    //MARK: - Helpers
    func completeTranslationForceHide(hide: Bool) {
        var center = self.view.center
        
        var shouldHide = hide
        if self.animatedImageView.center.y > 1.4 * self.view.center.y {
            center.y += self.view.bounds.size.height
            shouldHide = true
        } else if self.animatedImageView.center.y < 0.6 * self.view.center.y {
            center.y -= self.view.bounds.size.height
            shouldHide = true
        }
        
        if shouldHide {
            self.prepareUIForDissmissAndUpdateAnimatedViewFrame(false)
            self.hideImageAnimated(true)
            return
        }
        
        UIView.animateWithDuration(0.3, animations: { 
            var frame = self.animatedImageView.frame
            frame.origin.y = (self.view.bounds.size.height - frame.size.height) / 2
            self.animatedImageView.frame = frame
            
            self.overlayView.alpha = shouldHide ? 0.0 : 1.0
        }) { finished in
            if !shouldHide {
                self.collectionView?.hidden = false
                self.animatedImageView.hidden = true
                self.closeButton.hidden = false
                return
            }
            
            self.hideImageAnimated(true)
        }
    }
    
    func hideImageAnimated(animated: Bool) {
        self.indexPath = self.indexPathForCenterItem()
        
        let animations: () -> Void = { [weak self] in
            if let weakSelf = self {
                weakSelf.animatedImageView.transform = CGAffineTransformIdentity
                weakSelf.animatedImageView.frame = weakSelf.delegate.imagesFullScreenViewController(weakSelf, frameForIndexPath: weakSelf.indexPath!)!
                weakSelf.overlayView.alpha = 0.0
//                weakSelf.closeButton.alpha = 0.0
            }
        }
        self.closeButton.alpha = 0.0
        
        let completion: ((Bool) -> Void) = { [weak self] finished in
            self?.dismissViewControllerAnimated(false)
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
        if animated {
            UIView.animateWithDuration(0.3, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
    
    func dismissViewControllerAnimated(animated: Bool) {
        self.willHide = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    func updateCurrentTitle(forceUpdate: Bool) {
        self.indexPath = self.indexPathForCenterItem()
        
        if let cell = self.collectionView?.cellForItemAtIndexPath(self.indexPath!) as? ImagesFullScreenCell {
            self.animatedImageView.image = cell.imageView.image
            self.updateImageViewFrame()
        }
    }
    
    func updateImageViewFrame() {
        var imageSize = self.animatedImageView.image?.size
        let orientation = UIDevice.currentDevice().orientation
        
        if UIDeviceOrientationIsLandscape(orientation), let size = imageSize {
            imageSize = CGSizeMake(size.height, size.width)
        }
        self.animatedImageView.frame = CGRectWithAspectRatioInsideRect(imageSize!, boundingRect: self.view.window!.bounds)
    }
    
    func indexPathForCenterItem() -> NSIndexPath {
        let collectionView = self.collectionView
        let center = CGPointMake(collectionView!.contentOffset.x + 0.5 * collectionView!.bounds.size.width, collectionView!.contentOffset.y + 0.5 * collectionView!.bounds.size.height)
        
        return collectionView!.indexPathForItemAtPoint(center)!
    }
    
    func prepareUIForDissmissAndUpdateAnimatedViewFrame(updateAnimatedViewFrame: Bool) {
        self.willHide = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.view.removeGestureRecognizer(self.panGestureRecognizer!)
        self.delegate.imagesFullScreenViewController(self, prepareForDismissingWithIndexPath: self.indexPath!)
        
        let view = self.delegate.imagesFullScreenViewController(self, viewForIndexPath: self.indexPath!)
        
        self.animatedImageView.contentMode = view!.contentMode
        view?.hidden = true
        
        let captureView = self.presentingViewController?.view
        self.backgroundImageView.image = captureView?.captureImageByTakingScaleIntoAccount()
        view?.hidden = false
        
        if updateAnimatedViewFrame {
            let imageSize = self.animatedImageView.image?.size
            
            self.animatedImageView.transform = self.containerView.transform
            self.animatedImageView.frame = CGRectWithAspectRatioInsideRect(imageSize!, boundingRect: self.view.window!.bounds);
        }
    }

    func orientationChangedNotification() {
        let orientation = UIDevice.currentDevice().orientation
        let ignore = orientation == .Unknown || orientation == .FaceDown || orientation == .FaceUp
        
        if ignore {
            return
        }
        
        let indexPath = self.indexPath
        let content = self.dataSource?[indexPath!]
        let contentView = self.rotatingCell?.contentView
        
        if var contentView = contentView, let indexPath = indexPath {
            let currentCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? ImagesFullScreenCell
            let cell = self.cellController.nibToInstantiateCell(for:content)?.instantiateWithOwner(nil, options: nil).last as? ImagesFullScreenCell
            self.cellController.configureCell(cell!, for: content, at: indexPath)
            contentView = cell!.contentView
            self.rotatingCell = cell
            self.view.addSubview(contentView)
            
            contentView.frame = self.view.bounds
            
            contentView.transform = self.containerView.transform
            contentView.frame = self.containerView.frame
            cell?.layoutIfNeeded()
            cell?.updateMinimumZoomScale()
            cell?.scrollView.zoomScale = currentCell!.scrollView.zoomScale
            cell?.scrollView.contentOffset = currentCell!.scrollView.contentOffset
            cell?.scrollView.contentInset = currentCell!.scrollView.contentInset
            cell?.updateConstraintsForSize(contentView.bounds.size)
        }
        
        self.backgroundImageView.hidden = true
        self.animatedImageView.hidden = true
        self.collectionView?.hidden = true
        contentView?.hidden = false
        
        UIView.animateWithDuration(0.4, animations: { 
            self.rotateViewToMatchInterfaceOrientation()
            
            let orientation = UIDevice.currentDevice().orientation
            if orientation == .LandscapeLeft {
                contentView?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            } else if orientation == .LandscapeRight {
                contentView?.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            } else {
                contentView?.transform = CGAffineTransformIdentity
            }
            
            contentView?.frame = self.containerView.frame;
            contentView?.layoutIfNeeded()
        }) { finished in
            self.collectionView?.hidden = false
            self.backgroundImageView.hidden = false
            
            contentView?.removeFromSuperview()
            self.rotatingCell = nil
        }
    }
    
    func rotateViewToMatchInterfaceOrientation() {
        let orientation = UIDevice.currentDevice().orientation
        if orientation == .LandscapeLeft {
            self.rotateView(CGFloat(M_PI_2))
        } else if orientation == .LandscapeRight {
            self.rotateView(CGFloat(-M_PI_2))
        } else {
            self.rotateView(0)
        }
    }
    
    func rotateView(angle: CGFloat) {
        let indexPath = self.indexPath
        
        self.containerView.transform = angle == 0.0 ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(angle)
        self.containerView.frame = self.view.bounds

        let layout = self.collectionView?.collectionViewLayout
        layout?.invalidateLayout()
        layout?.prepareLayout()

        if let indexPath = indexPath {
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
        }
    }
    
    override public func shouldAutorotate() -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool{
        if gestureRecognizer == self.panGestureRecognizer {
            return CGAffineTransformIsIdentity(self.containerView.transform)
        } else {
            return true
        }
    }
}
