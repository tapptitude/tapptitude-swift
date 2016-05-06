//
//  CollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class CollectionCellController<ObjectClass, CellName: UICollectionViewCell> : TTCollectionCellController, TTCollectionCellControllerSize {
    public typealias ObjectType = ObjectClass
    public typealias CellType = CellName
    
    public var cellSizeForContent : ((content: ObjectType, collectionView: UICollectionView) -> CGSize)?
    public var configureCell : ((cell: CellType, content: ObjectType, indexPath: NSIndexPath) -> Void)?
    public var didSelectContent : ((content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) -> Void)?
    
    public var sectionInset = UIEdgeInsetsZero
    public var minimumLineSpacing: CGFloat = 0.0
    public var minimumInteritemSpacing: CGFloat = 0.0
    public var cellSize : CGSize
    public var reuseIdentifier: String
    
    public weak var parentViewController : UIViewController?
    
    public init(cellSize : CGSize, reuseIdentifier: String = String(CellType)) {
        self.cellSize = cellSize
        self.reuseIdentifier = reuseIdentifier
    }
    
    public func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize {
        let blockCellSize = cellSizeForContent?(content: content, collectionView: collectionView)
        return blockCellSize ?? cellSize
    }
    
    public func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath) {
        configureCell?(cell: cell, content: content, indexPath: indexPath)
    }
    
    public func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) {
        didSelectContent?(content: content, indexPath: indexPath, collectionView: collectionView)
    }
    
    
    var _sizeCalculationCell: CellType!
    
    public var sizeCalculationCell: CellType! {
        if _sizeCalculationCell == nil {
            var sizeCalculationCell: CellType! = nil
            if let nib = nibToInstantiateCell() {
                sizeCalculationCell = nib.instantiateWithOwner(nil, options: nil).last as! CellType
            } else {
                sizeCalculationCell = CellType(frame: CGRect(origin: CGPointZero, size: self.cellSize))
            }
            
            let deviceWidth = UIScreen.mainScreen().bounds.size.width
            let cellWidth = sizeCalculationCell.frame.size.width
            if (cellWidth == 320.0 && deviceWidth != cellWidth) {
                var frame = sizeCalculationCell.frame
                frame.size.width = deviceWidth
                sizeCalculationCell.frame = frame
                sizeCalculationCell.contentView.frame = frame
                sizeCalculationCell.layoutIfNeeded()
            }
            
            _sizeCalculationCell = sizeCalculationCell
        }
        
        return _sizeCalculationCell!
    }
    
    public func acceptsContent(content: Any) -> Bool {
        if let content = content as? ObjectType {
            return acceptsContent(content)
        } else {
            return false
        }
    }
    
    public func acceptsContent(content: ObjectType) -> Bool {
        return true
    }
    
    func nibToInstantiateCell() -> UINib? {
        if let _ = NSBundle.mainBundle().pathForResource(reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
    }
    
    public func reuseIdentifierForContent(content: ObjectType) -> String {
        return reuseIdentifier
    }
}