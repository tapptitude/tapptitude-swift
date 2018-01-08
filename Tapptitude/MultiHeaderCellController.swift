//
//  MultiHeaderCellController.swift
//  Pods
//
//  Created by Efraim Budusan on 7/25/17.
//
//

import Foundation
import UIKit

open class MultiHeaderCellController: TTAnyCollectionHeaderController {

    public init (_ headerControllers: [TTAnyCollectionHeaderController]) {
        self.headerControllers = headerControllers
    }
    
    public init (_ headerControllers: TTAnyCollectionHeaderController...) {
        self.headerControllers = headerControllers
    }
    
    public convenience required init(arrayLiteral elements: TTAnyCollectionHeaderController...) {
        self.init(elements.map({ $0 }))
    }
    
    open var headerControllers: [TTAnyCollectionHeaderController] = [] {
        willSet {
            for var headerController in headerControllers {
                headerController.parentViewController = nil
            }
            previousCellController = nil
        }
        
        didSet {
            for var headerController in headerControllers {
                headerController.parentViewController = parentViewController
            }
        }
    }
    
    fileprivate var previousCellController: TTAnyCollectionHeaderController? // TODO: check if we should use weak
    
    
    open func controllerForContent(_ content: Any) -> TTAnyCollectionHeaderController? {
        if previousCellController?.acceptsContent(content) == true { // for performance update
            return previousCellController
        }
        
        for headerController in headerControllers {
            if headerController.acceptsContent(content) == true {
                previousCellController = headerController
                return headerController
            }
        }
        return nil
    }

    
    public func classToInstantiate(for content:Any) -> AnyClass? {
        return controllerForContent(content)?.classToInstantiate(for: content)
    }
    public func nibToInstantiate(for content:Any) -> UINib? {
        return controllerForContent(content)?.nibToInstantiate(for: content)
    }
    
    public func reuseIdentifier(for content: Any) -> String {
        return controllerForContent(content)!.reuseIdentifier(for: content)
    }
    
    open var reuseIdentifier: String {
        return ""
    }
    public var headerSize: CGSize {
        return CGSize.zero
    }
    
    weak public var parentViewController : UIViewController?
    
    public func acceptsContent(_ content: Any) -> Bool {
        return controllerForContent(content) != nil
    }
    
    public func headerSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return controllerForContent(content)!.headerSize(for:content,in:collectionView)
    }
    
    public func configureHeader(_ header: UICollectionReusableView, for content: Any, at indexPath: IndexPath) {
        controllerForContent(content)!.configureHeader(header, for: content, at: indexPath)
    }


}

extension MultiHeaderCellController: ExpressibleByArrayLiteral {
    
}

