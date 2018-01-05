//
//  CollectionCellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

open class CollectionCellController<ContentName, CellName: UICollectionViewCell> : TTCollectionCellController, TTCollectionCellControllerSize {
    public typealias ContentType = ContentName
    public typealias CellType = CellName
    
    open var cellSizeForContent : ((_ content: ContentType, _ collectionView: UICollectionView) -> CGSize)?
    open var configureCell : ((_ cell: CellType, _ content: ContentType, _ indexPath: IndexPath) -> Void)?
    open var didSelectContent : ((_ content: ContentType, _ indexPath: IndexPath, _ collectionView: UICollectionView) -> Void)?
    
    open var sectionInset = UIEdgeInsets.zero
    open var minimumLineSpacing: CGFloat = 0.0
    open var minimumInteritemSpacing: CGFloat = 0.0
    open var cellSize : CGSize
    open var reuseIdentifier: String
    
    open weak var parentViewController : UIViewController?
    
    public init(cellSize : CGSize, reuseIdentifier: String = String(describing: CellType.self)) {
        self.cellSize = cellSize
        self.reuseIdentifier = reuseIdentifier
    }
    
    open func cellSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize {
        let blockCellSize = cellSizeForContent?(content, collectionView)
        return blockCellSize ?? cellSize
    }
    
    open func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath) {
        configureCell?(cell, content, indexPath)
    }
    
    open func didSelectContent(_ content: ContentType, at indexPath: IndexPath, in collectionView: UICollectionView) {
        didSelectContent?(content, indexPath, collectionView)
    }
    
    
    var _sizeCalculationCell: CellType!
    
    open var sizeCalculationCell: CellType! {
        if _sizeCalculationCell == nil {
            var sizeCalculationCell: CellType! = nil
            if let nib = nibToInstantiateCell() {
                sizeCalculationCell = nib.instantiate(withOwner: nil, options: nil).last as! CellType
            } else {
                sizeCalculationCell = CellType(frame: CGRect(origin: CGPoint.zero, size: self.cellSize))
            }
            
            if cellSize.width < 0 || cellSize.height < 0 {
                if let parent = self.parentViewController as? __CollectionFeedController, let size = parent.collectionView?.bounds.size {
                    var frame = sizeCalculationCell.frame
                    frame.size.width = cellSize.width < 0 ? size.width : cellSize.width
                    frame.size.height = cellSize.height < 0 ? size.height : cellSize.height
                    sizeCalculationCell.frame = frame
                    sizeCalculationCell.setNeedsLayout()
                    sizeCalculationCell.layoutIfNeeded()
                }
            }
            
            _sizeCalculationCell = sizeCalculationCell
        }
        return _sizeCalculationCell!
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
    
    open func nibToInstantiateCell() -> UINib? {
        return nibToInstantiateCell(reuseIdentifier: reuseIdentifier)
    }
    
    open func nibToInstantiateCell(for content: ContentType) -> UINib? {
        let reuseIdentifier = self.reuseIdentifier(for: content)
        return nibToInstantiateCell(reuseIdentifier: reuseIdentifier)
    }
    
    open func nibToInstantiateCell(reuseIdentifier: String) -> UINib? {
        if let _ = Bundle(for: CellType.self).path(forResource: reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: Bundle(for: CellType.self))
        } else {
            return nil
        }
    }
    
    open func reuseIdentifier(for content: ContentType) -> String {
        return reuseIdentifier
    }
    
    open func allSupportedReuseIdentifiers() -> [String] {
        return [reuseIdentifier]
    }
    
    open func classToInstantiateCell(for content: ContentType) -> AnyClass? {
        return CellType.self
    }
    
    open func sectionInset(for content: ContentType, in collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInset
    }
    open func minimumLineSpacing(for content: ContentType, in collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacing
    }
    open func minimumInteritemSpacing(for content: ContentType, in collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacing
    }
}
