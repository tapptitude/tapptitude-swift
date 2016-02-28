//
//  CellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTCollectionCellControllerProtocol {
    func acceptsContent(content: AnyObject) -> Bool
    
    func classToInstantiateCellForContent(content: AnyObject) -> AnyClass?
    func nibToInstantiateCellForContent(content: AnyObject) -> UINib?
    
    func reuseIdentifierForContent(content: AnyObject) -> String
    
    func configureCell(cell: UICollectionViewCell, forContent content: AnyObject, indexPath: NSIndexPath)
    
    func didSelectContent(content: AnyObject, indexPath: NSIndexPath, collectionView: UICollectionView)
    
    var parentViewController: UIViewController? { get set }
    
    var cellSize : CGSize { get }
    var sectionInset : UIEdgeInsets { get }
    var minimumLineSpacing : CGFloat { get }
    var minimumInteritemSpacing : CGFloat { get }
    
    func cellSizeForContent(content: AnyObject, collectionView: UICollectionView) -> CGSize
    func sectionInsetForContent(content: AnyObject, collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacingForContent(content: AnyObject, collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacingForContent(content: AnyObject, collectionView: UICollectionView) -> CGFloat
    
    // TODO: implement as option protocolo
    //    func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize
    //
    //    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath, dataSourceCount count: Int)
    //
    //    func shouldHighlightContent(content: ObjectType, atIndexPath indexPath: NSIndexPath) -> Bool
}

public protocol TTCollectionCellController : TTCollectionCellControllerProtocol {
    typealias ObjectType
    typealias CellType
    
    func classToInstantiateCellForContent(content: ObjectType) -> AnyClass?
    func nibToInstantiateCellForContent(content: ObjectType) -> UINib?
    
    func reuseIdentifierForContent(content: ObjectType) -> String
    
    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath)
    
    func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView)
    
    func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize
    func sectionInsetForContent(content: ObjectType, collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacingForContent(content: ObjectType, collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacingForContent(content: ObjectType, collectionView: UICollectionView) -> CGFloat
}

protocol TTCollectionCellControllerSize : TTCollectionCellController {
    func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize
    
    func sizeCalculationCell() -> CellType
    
    func cellSizeToFitText(text: String, forCellLabelKeyPath labelKeyPath: String, maxSize: CGSize) -> CGSize
    //    func cellSizeToFitText(text: String, forCellLabelKeyPath labelKeyPath: String) -> CGSize // stretch height to max 1024 (label)
    func cellSizeToFitAttributedText(text: NSAttributedString, forCellLabelKeyPath labelKeyPath: String, maxSize: CGSize) -> CGSize
    //    func cellSizeToFitAttributedText(text: NSAttributedString, forCellLabelKeyPath labelKeyPath: String) -> CGSize
}



extension TTCollectionCellController {
    public func acceptsContent(content: AnyObject) -> Bool {
        return content is ObjectType
    }
    
    // TODO: enable passing multiple cell xibs with same cell class but different reuse identifiers
    public func classToInstantiateCellForContent(content: ObjectType) -> AnyClass? {
        if let classType = CellType.self as? AnyClass {
            return classType
        } else {
            return nil
        }
    }
    
    public func nibToInstantiateCellForContent(content: ObjectType) -> UINib? {
        let reuseIdentifier = reuseIdentifierForContent(content)
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    public var reuseIdentifier: String {
        return String(CellType)
    }
    
    public func reuseIdentifierForContent(content: ObjectType) -> String {
        return reuseIdentifier
    }
    
    public func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath) {
        
    }
    
    public func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) {
        
    }
    
    public func classToInstantiateCellForContent(content: AnyObject) -> AnyClass? {
        return classToInstantiateCellForContent(content as! ObjectType)
    }
    public func nibToInstantiateCellForContent(content: AnyObject) -> UINib? {
        return nibToInstantiateCellForContent(content as! ObjectType)
    }
    public func reuseIdentifierForContent(content: AnyObject) -> String {
        return reuseIdentifierForContent(content as! ObjectType)
    }
    public func configureCell(cell: UICollectionViewCell, forContent content: AnyObject, indexPath: NSIndexPath) {
        configureCell(cell as! CellType, forContent: content as! ObjectType, indexPath: indexPath)
    }
    public func didSelectContent(content: AnyObject, indexPath: NSIndexPath, collectionView: UICollectionView) {
        didSelectContent(content as! ObjectType, indexPath: indexPath, collectionView: collectionView)
    }
    
    public func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize {
        return cellSize
    }
    public func sectionInsetForContent(content: ObjectType, collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInset
    }
    public func minimumLineSpacingForContent(content: ObjectType, collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacing
    }
    public func minimumInteritemSpacingForContent(content: ObjectType, collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    public func cellSizeForContent(content: AnyObject, collectionView: UICollectionView) -> CGSize {
        return cellSizeForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func sectionInsetForContent(content: AnyObject, collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInsetForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func minimumLineSpacingForContent(content: AnyObject, collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacingForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func minimumInteritemSpacingForContent(content: AnyObject, collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacingForContent(content as! ObjectType, collectionView: collectionView)
    }
}

extension UICollectionViewCell {
    private struct AssociatedKey {
        static var viewExtension = "viewExtension"
    }
    
    public var parentViewController : UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.viewExtension) as? UIViewController ?? nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.viewExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}