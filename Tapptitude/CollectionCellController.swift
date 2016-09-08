//
//  CollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public class CollectionCellController<ObjectClass, CellName: UICollectionViewCell> : TTCollectionCellController, TTCollectionCellControllerSize {
    public typealias ContentType = ObjectClass
    public typealias CellType = CellName
    
    public var cellSizeForContent : ((content: ContentType, collectionView: UICollectionView) -> CGSize)?
    public var configureCell : ((cell: CellType, content: ContentType, indexPath: NSIndexPath) -> Void)?
    public var didSelectContent : ((content: ContentType, indexPath: NSIndexPath, collectionView: UICollectionView) -> Void)?
    public var setPreferredSizeOfLabels: ((cell: CellType, laidOutCell: CellType) -> Void)?
    
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
    
    public func cellSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        let blockCellSize = cellSizeForContent?(content: content, collectionView: collectionView)
        return blockCellSize ?? cellSize
    }
    
    public func configureCell(cell: CellType, for content: ContentType, at indexPath: NSIndexPath) {
        if let parent = self.parentViewController as? CollectionFeedController {
            if let layout = parent.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                if layout.estimatedItemSize != CGSizeZero {
                    assert(setPreferredSizeOfLabels != nil, "Implementation for setPrefferedSizeOfLabels is missing")
                    self.setPreferredSizeOfLabels?(cell:cell,laidOutCell: self.sizeCalculationCell)
                }
            }
        }
        configureCell?(cell: cell, content: content, indexPath: indexPath)
    }
    
    public func didSelectContent(content: ContentType, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
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
            
            var size: CGSize! = nil
            if let parent = self.parentViewController as? CollectionFeedController {
                size = parent.collectionView?.bounds.size
            }
            
            var frame = sizeCalculationCell.frame
            frame.size.width = cellSize.width < 0 ? size.width : cellSize.width
            frame.size.height = cellSize.height < 0 ? size.height : cellSize.height
            sizeCalculationCell.frame = frame
            sizeCalculationCell.setNeedsLayout()
            sizeCalculationCell.layoutIfNeeded()
            
            _sizeCalculationCell = sizeCalculationCell
        }
        return _sizeCalculationCell!
    }
    
    public func acceptsContent(content: Any) -> Bool {
        if let content = content as? ContentType {
            return acceptsContent(content)
        } else {
            return false
        }
    }
    
    public func acceptsContent(content: ContentType) -> Bool {
        return true
    }
    
    func nibToInstantiateCell() -> UINib? {
        if let _ = NSBundle.mainBundle().pathForResource(reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
    }
    
    public func reuseIdentifier(for content: ContentType) -> String {
        return reuseIdentifier
    }
}