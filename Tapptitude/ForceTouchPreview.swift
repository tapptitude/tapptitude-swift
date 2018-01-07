//
//  ForceTouchPreview.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 02/04/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import UIKit

public class ForceTouchPreview: NSObject, UIViewControllerPreviewingDelegate {
    weak var collectionController: TTCollectionFeedController!
    weak var parentViewController: UIViewController?
    internal weak var forceTouchPreviewContext: UIViewControllerPreviewing?
    
    public init(collectionController: TTCollectionFeedController, in viewController: UIViewController) {
        self.collectionController = collectionController
        self.parentViewController = viewController
        super.init()
       setupForceTouchPreview()
    }
    
    public init(collectionController: __CollectionFeedController) {
        self.collectionController = collectionController
        self.parentViewController = collectionController
        super.init()
        setupForceTouchPreview()
    }
    
    deinit {
        unregisterForceTouchPreview()
    }
    
    public func setupForceTouchPreview() {
        if parentViewController?.isViewLoaded == true {
            registerForceTouchPreview()
        }
    }
    
    internal func registerForceTouchPreview() {
        if #available(iOS 9, *) {
            if parentViewController!.traitCollection.forceTouchCapability == .available  && forceTouchPreviewContext == nil {
                forceTouchPreviewContext = parentViewController!.registerForPreviewing(with: self, sourceView: parentViewController!.view!)
            }
        }
    }
    internal func unregisterForceTouchPreview() {
        if #available(iOS 9, *) {
            if parentViewController?.traitCollection.forceTouchCapability == .available {
                if let context = forceTouchPreviewContext {
                    parentViewController!.unregisterForPreviewing(withContext: context)
                    forceTouchPreviewContext = nil
                }
            }
        }
    }
    
    
    @available(iOS 9.0, *)
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = collectionController.collectionView.convert(location, from: parentViewController!.view)
        guard let indexPath = collectionController.collectionView.indexPathForItem(at: point) else {
            return nil
        }
        
        let content = collectionController._dataSource!.item(at: indexPath)
        let cellController = collectionController._cellController
        let previousParentController = cellController?.parentViewController
        let parentController = UIViewController()
        var dummyNavigationController: DummyNavigationController? = DummyNavigationController(rootViewController: parentController)
        cellController?.parentViewController = parentController
        cellController?.didSelectContent(content, at: indexPath, in: collectionController.collectionView)
        cellController?.parentViewController = previousParentController
        
        let controller = dummyNavigationController!.capturedViewController
        dummyNavigationController = nil // destroy
        if let controller = controller {
            controller.preferredContentSize = CGSize.zero
            
            let cell = collectionController.collectionView.cellForItem(at: indexPath)
            previewingContext.sourceRect = cell!.convert(cell!.bounds, to:parentViewController!.view)
        }
        
        return controller
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        parentViewController!.show(viewControllerToCommit, sender: self)
    }
    
    
//    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        if forceTouchPreviewContext == nil && forceTouchPreviewEnabled {
//            registerForceTouchPreview()
//        }
//    }
}

internal class DummyNavigationController : UINavigationController {
    var capturedViewController: UIViewController?
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty {
            capturedViewController = viewController
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
}
