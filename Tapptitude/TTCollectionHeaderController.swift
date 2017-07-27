//
//  CollectionHeaderController.swift
//  Pods
//
//  Created by Alexandru Tudose on 11/04/16.
//
//

import UIKit

public protocol TTAnyCollectionHeaderController {
    func classToInstantiate(for content: Any) -> AnyClass?
    func nibToInstantiate(for content: Any) -> UINib?
    func reuseIdentifier(for content: Any) -> String
    
    var headerSize: CGSize {get}
    
    weak var parentViewController : UIViewController? {get set}
    
    func acceptsContent(_ content: Any) -> Bool
    
    func headerSize(for content: Any, in collectionView: UICollectionView) -> CGSize
    
    func configureHeader(_ header: UICollectionReusableView, for content: Any, at indexPath: IndexPath)
}

public protocol TTCollectionHeaderController: TTAnyCollectionHeaderController {
    associatedtype ContentType
    associatedtype HeaderType: UICollectionReusableView
    
    func headerSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize
    func configureHeader(_ cell: HeaderType, for content: ContentType, at indexPath: IndexPath)
}

extension TTCollectionHeaderController {
    public func classToInstantiate(for content: Any) -> AnyClass? {
        return HeaderType.self
    }
    
    public func nibToInstantiate(for content: Any) -> UINib? {
        let reuseIdentifier = self.reuseIdentifier(for: content)
        if let _ = Bundle(for: HeaderType.self).path(forResource: reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: Bundle(for: HeaderType.self))
        } else {
            return nil
        }
    }
    
    public func headerSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return headerSize(for: content as! ContentType, in: collectionView)
    }
    
    public func configureHeader(_ header: UICollectionReusableView, for content: Any, at indexPath: IndexPath) {
        configureHeader(header as! HeaderType, for: content as! ContentType, at: indexPath)
    }
}

open class CollectionHeaderController<ItemType, HeaderName: UICollectionReusableView> : TTCollectionHeaderController {
    public typealias ContentType = ItemType
    public typealias HeaderType = HeaderName
    
    open var headerSizeForContent : ((_ content: ContentType, _ collectionView: UICollectionView) -> CGSize)?
    open var configureHeader : ((_ header: HeaderType, _ content: ContentType, _ indexPath: IndexPath) -> Void)?
    
    
    open var headerSize : CGSize
    open var reuseIdentifier: String
    
    open weak var parentViewController : UIViewController?
    
    public init(headerSize : CGSize, reuseIdentifier:String? = nil) {
        self.headerSize = headerSize
        self.reuseIdentifier = reuseIdentifier ?? String(describing: HeaderType.self)
    }
    
    open func reuseIdentifier(for content: ContentType) -> String {
        return reuseIdentifier
    }
    
    public func reuseIdentifier(for content: Any) -> String {
        return reuseIdentifier(for: content as! ContentType)
    }
    
    open func headerSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        let blockCellSize = headerSizeForContent?(content, collectionView)
        return blockCellSize ?? headerSize
    }
    
    open func configureHeader(_ header: HeaderType, for content: ContentType, at indexPath: IndexPath) {
        self.configureHeader?(header, content, indexPath)
    }
    
    open func acceptsContent(_ content: Any) -> Bool {
        if let content = content as? ContentType {
            return acceptsContent(content)
        } else {
            return false
        }
    }
    
    open func acceptsContent(_ content: ContentType) -> Bool {
        return true
    }
}
