//
//  NDetailSlideshowCellController.swift
//  Bildnytt
//
//  Created by Ion Toderasco on 13/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

public protocol ImageResource {
    var image:UIImage { get }
}

public class NDetailSlideshowCellController: CollectionCellController<ImageResource, NDetailSlideshowCell> {
    weak var liftCollectionView: UICollectionView?
    weak var circulalController: CircularCollectionController?
    
    public init() {
        super.init(cellSize: CGSize(width: -1.0, height: 100))
    }

    override public func configureCell(cell: NDetailSlideshowCell, for content: ImageResource, at indexPath: NSIndexPath!) {
        cell.imageView.image = content.image
    }
    
    override public func didSelectContent(content: ImageResource, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        self.liftCollectionView = collectionView

        let parent = self.parentViewController as! CollectionFeedController
        
        var photos: [AnyObject] = (parent.dataSource?.content.filter({ $0 is ImageResource}))!.map({ $0 as! AnyObject})
        
        let viewController = FullScreenImageViewController(nibName: "FullScreenImageViewController", bundle: NSBundle(forClass: FullScreenImageViewController.self))
        
        viewController.configureForContent(photos, displayIndex: indexPath.item)
        let _ = viewController.view
        
        self.liftCollectionView = collectionView
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? NDetailSlideshowCell
        viewController.liftedImageView = cell?.imageView
        cell?.imageView.hidden = true
        viewController.backgroundImageView.image = collectionView.window?.captureImageByTakingScaleIntoAccount()
        cell?.imageView.hidden = false
        viewController.delegate = self
        
        parent.presentViewController(viewController, animated: true, completion: nil)
        
    }
}

extension NDetailSlideshowCellController: ImagesFullScreenViewControllerDelegate {
    func imagesFullScreenViewController(controller: FullScreenImageViewController, prepareForDismissingWithIndexPath indexPath: NSIndexPath) {
        guard let collectionView = self.liftCollectionView else {
            return
        }
        let attribute = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout where layout.scrollDirection == .Horizontal {
            let center = attribute.center
            var offset = CGPointMake(center.x - collectionView.bounds.size.width * 0.5, 0)
            
            offset.x = min(offset.x, collectionView.contentSize.width - collectionView.bounds.size.width)
            offset.x = max(0, offset.x)
            
            if (indexPath.item == 0) {
                offset.x = 0;
            }
            collectionView.contentOffset = offset
        } else {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
        }
    }
    
    func imagesFullScreenViewController(controller: FullScreenImageViewController, viewForIndexPath indexPath: NSIndexPath) -> UIView? {
        guard let collectionView = self.liftCollectionView else {
            return nil
        }
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as? NDetailSlideshowCell
        
        if cell == nil {
            collectionView.layoutSubviews()
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? NDetailSlideshowCell
        }
        return cell?.imageView
    }
    
    func imagesFullScreenViewController(controller: FullScreenImageViewController, frameForIndexPath indexPath: NSIndexPath) -> CGRect? {
        guard let collectionView = self.liftCollectionView else {
            return nil
        }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let frame = layout.layoutAttributesForItemAtIndexPath(indexPath)?.frame
            return controller.view.window!.convertRect(frame!, fromView: collectionView)
        }
        
        return nil
    }
}
