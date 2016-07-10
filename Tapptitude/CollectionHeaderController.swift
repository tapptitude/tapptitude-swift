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
    
    func acceptsContent(content: Any) -> Bool
    
    func headerSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize
    
    func configureHeader(cell: UICollectionReusableView, forContent content: Any, indexPath: NSIndexPath)
}

public protocol TTCollectionHeaderController: TTCollectionHeaderControllerProtocol {
    associatedtype ObjectType
    associatedtype HeaderType: UICollectionReusableView
    
    func classToInstantiate() -> AnyClass?
    func nibToInstantiate() -> UINib?
    
    var reuseIdentifier: String {get}
    var headerSize: CGSize {get}
    
    func headerSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize
    func configureHeader(cell: HeaderType, forContent content: ObjectType, indexPath: NSIndexPath)
}

extension TTCollectionHeaderController {
    public func classToInstantiate() -> AnyClass? {
        return HeaderType.self
    }
    
    public func nibToInstantiate() -> UINib? {
        if let _ = NSBundle.mainBundle().pathForResource(reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
    }
    
    public func headerSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize {
        return headerSizeForContent(content as! ObjectType, collectionView: collectionView)
    }
    
    public func configureHeader(cell: UICollectionReusableView, forContent content: Any, indexPath: NSIndexPath) {
        configureHeader(cell as! HeaderType, forContent: content as! ObjectType, indexPath: indexPath)
    }
    
    public func acceptsContent(content: Any) -> Bool {
        return content is ObjectType
    }
}

public class CollectionHeaderController<ItemType, HeaderName: UICollectionReusableView> : TTCollectionHeaderController {
    public typealias ObjectType = ItemType
    public typealias HeaderType = HeaderName
    
    public var headerSizeForContent : ((content: ObjectType, collectionView: UICollectionView) -> CGSize)?
    public var configureHeader : ((header: HeaderType, content: ObjectType, indexPath: NSIndexPath) -> Void)?
    
    
    public var headerSize : CGSize
    public var reuseIdentifier: String
    
    public weak var parentViewController : UIViewController?
    
    public init(headerSize : CGSize, reuseIdentifier:String? = nil) {
        self.headerSize = headerSize
        self.reuseIdentifier = reuseIdentifier ?? String(HeaderType)
    }
    
    public func headerSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize {
        let blockCellSize = headerSizeForContent?(content: content, collectionView: collectionView)
        return blockCellSize ?? headerSize
    }
    
    public func configureHeader(header: HeaderType, forContent content: ObjectType, indexPath: NSIndexPath) {
        configureHeader?(header: header, content: content, indexPath: indexPath)
    }
}