//
//  CollectionHeaderController.swift
//  Pods
//
//  Created by Alexandru Tudose on 11/04/16.
//
//

import UIKit

public protocol TTCollectionHeaderControllerProtocol {
    func classToInstantiate() -> AnyClass?
    func nibToInstantiate() -> UINib?
    
    var reuseIdentifier: String {get}
    var headerSize: CGSize {get}
    
    weak var parentViewController : UIViewController? {get set}
    
    func acceptsContent(_ content: Any) -> Bool
    
    func headerSize(for content: Any, in collectionView: UICollectionView) -> CGSize
    
    func configureHeader(_ header: UICollectionReusableView, for content: Any, at indexPath: IndexPath)
}

public protocol TTCollectionHeaderController: TTCollectionHeaderControllerProtocol {
    associatedtype ContentType
    associatedtype HeaderType: UICollectionReusableView
    
    func classToInstantiate() -> AnyClass?
    func nibToInstantiate() -> UINib?
    
    var reuseIdentifier: String {get}
    var headerSize: CGSize {get}
    
    func headerSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize
    func configureHeader(_ cell: HeaderType, for content: ContentType, at indexPath: IndexPath)
}

extension TTCollectionHeaderController {
    public func classToInstantiate() -> AnyClass? {
        return HeaderType.self
    }
    
    public func nibToInstantiate() -> UINib? {
        if let _ = Bundle.main.path(forResource: reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
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
    
    public func acceptsContent(_ content: Any) -> Bool {
        return content is ContentType
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
    
    open func headerSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        let blockCellSize = headerSizeForContent?(content, collectionView)
        return blockCellSize ?? headerSize
    }
    
    open func configureHeader(_ header: HeaderType, for content: ContentType, at indexPath: IndexPath) {
        self.configureHeader?(header, content, indexPath)
    }
}
