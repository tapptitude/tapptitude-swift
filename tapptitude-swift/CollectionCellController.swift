//
//  CollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class CollectionCellController<ObjectClass, CellName> : TTCollectionCellController {
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
    
    public init(cellSize : CGSize, reuseIdentifier:String? = nil) {
        self.cellSize = cellSize
        self.reuseIdentifier = reuseIdentifier ?? String(CellType)
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
}