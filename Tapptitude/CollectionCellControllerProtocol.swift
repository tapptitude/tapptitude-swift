//
//  CellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTCollectionCellControllerProtocol {
    func acceptsContent(content: Any) -> Bool
    
    func classToInstantiateCell(for content: Any) -> AnyClass?
    func nibToInstantiateCell(for content: Any) -> UINib?
    
    func reuseIdentifier(for content: Any) -> String
    
    func configureCell(cell: UICollectionViewCell, for content: Any, at indexPath: NSIndexPath)
    
    func didSelectContent(content: Any, at indexPath: NSIndexPath, in collectionView: UICollectionView)
    
    weak var parentViewController: UIViewController? { get set }
    
    var cellSize : CGSize { get }
    var sectionInset : UIEdgeInsets { get }
    var minimumLineSpacing : CGFloat { get }
    var minimumInteritemSpacing : CGFloat { get }
    
    func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize
    func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat
}

// TODO: implement as option protocol
public protocol TTCollectionCellControllerProtocolExtended {
    func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath, dataSourceCount count: Int)
    func shouldHighlightContent(content: Any, atIndexPath indexPath: NSIndexPath) -> Bool
}

public protocol TTCollectionCellController : TTCollectionCellControllerProtocol {
    associatedtype ObjectType
    associatedtype CellType: UICollectionViewCell
    
    func classToInstantiateCell(for content: ObjectType) -> AnyClass?
    func nibToInstantiateCell(for content: ObjectType) -> UINib?
    
    func reuseIdentifier(for content: ObjectType) -> String
    
    func configureCell(cell: CellType, for content: ObjectType, at indexPath: NSIndexPath)
    
    func didSelectContent(content: ObjectType, at indexPath: NSIndexPath, in collectionView: UICollectionView)
    
    func cellSize(for content: ObjectType, in collectionView: UICollectionView) -> CGSize
    func sectionInset(for content: ObjectType, in collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacing(for content: ObjectType, in collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacing(for content: ObjectType, in collectionView: UICollectionView) -> CGFloat
}

public protocol TTCollectionCellControllerSize: TTCollectionCellController {
    var sizeCalculationCell: CellType! {get}
    
    func cellSizeToFit(text text: String, labelName: String, maxSize: CGSize) -> CGSize
    func cellSizeToFit(text text: String, labelName: String) -> CGSize // stretch height to max 2040 (label)
    
    func cellSizeToFit(attributedText attributedText: NSAttributedString, labelName: String, maxSize: CGSize) -> CGSize
    func cellSizeToFit(attributedText attributedText: NSAttributedString, labelName: String) -> CGSize
}

extension TTCollectionCellControllerSize {
    public func cellSizeToFit(text text: String, labelName: String, maxSize: CGSize) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        let label: UILabel = sizeCalculationCell.valueForKey(labelName) as! UILabel
        var maxSize = maxSize
        
        label.text = text;
        
        if (maxSize.width < 0) {
            assert(label.lineBreakMode == .ByWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
            assert(label.numberOfLines != 1, "Label number of lines should be set to 0")
            maxSize.width = label.bounds.size.width
            let  newLabelSize = label.sizeThatFits(maxSize)
            size.height += newLabelSize.height - label.bounds.size.height
            size.width = cellSize.width
        } else if (maxSize.height < 0) {
            maxSize.height = label.bounds.size.height
            let newLabelSize = label.sizeThatFits(maxSize)
            size.width += newLabelSize.width - label.bounds.size.width
            size.height = cellSize.height;
        }
        
        return size;
    }
    
    public func cellSizeToFit(text text: String, labelName: String) -> CGSize { // stretch height to max 2040 (label)
        return cellSizeToFit(text: text, labelName: labelName, maxSize: CGSizeMake(-1, 2040))
    }
    
    public func cellSizeToFit(attributedText attributedText: NSAttributedString, labelName: String, maxSize: CGSize) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        let label: UILabel = sizeCalculationCell.valueForKey(labelName) as! UILabel
        var maxSize = maxSize
        
        label.attributedText = attributedText;
        
        if (maxSize.width < 0) {
            assert(label.lineBreakMode == .ByWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
            maxSize.width = label.bounds.size.width
            let newLabelSize = label.sizeThatFits(maxSize)
            size.height += newLabelSize.height - label.bounds.size.height
            size.width = cellSize.width
        } else if (maxSize.height < 0) {
            maxSize.height = label.bounds.size.height
            let newLabelSize = label.sizeThatFits(maxSize)
            size.width += newLabelSize.width - label.bounds.size.width
            size.height = cellSize.height;
        } else {
            assert(label.lineBreakMode == .ByWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
            var frame = sizeCalculationCell.frame
            frame.size.width = maxSize.width
            sizeCalculationCell.frame = frame
            self.sizeCalculationCell.layoutSubviews()
            maxSize.width = label.bounds.size.width
            let newLabelSize = label.sizeThatFits(maxSize)
            size.height += newLabelSize.height - label.bounds.size.height
            size.width = cellSize.width
        }
        
        return size;
    }
    
    public func cellSizeToFit(attributedText attributedText: NSAttributedString, labelName: String) -> CGSize {
        return cellSizeToFit(attributedText: attributedText, labelName: labelName, maxSize: CGSizeMake(-1, 2040))
    }
}



extension TTCollectionCellController {
    public func acceptsContent(content: Any) -> Bool {
        return content is ObjectType
    }
    
    public func classToInstantiateCell(for content: ObjectType) -> AnyClass? {
        return CellType.self
    }
    
    public func nibToInstantiateCell(for content: ObjectType) -> UINib? {
        let reuseIdentifier = self.reuseIdentifier(for: content)
        if let _ = NSBundle.mainBundle().pathForResource(reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
    }
    
    public var reuseIdentifier: String {
        return String(CellType)
    }
    
    public func reuseIdentifier(for content: ObjectType) -> String {
        return reuseIdentifier
    }
    
    public func configureCell(cell: CellType, for content: ObjectType, at indexPath: NSIndexPath) {
        
    }
    
    public func didSelectContent(content: ObjectType, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        
    }
    
    public func classToInstantiateCell(for content: Any) -> AnyClass? {
        return classToInstantiateCell(for: content as! ObjectType)
    }
    public func nibToInstantiateCell(for content: Any) -> UINib? {
        return nibToInstantiateCell(for: content as! ObjectType)
    }
    public func reuseIdentifier(for content: Any) -> String {
        return reuseIdentifier(for: content as! ObjectType)
    }
    public func configureCell(cell: UICollectionViewCell, for content: Any, at indexPath: NSIndexPath) {
        configureCell(cell as! CellType, for: content as! ObjectType, at: indexPath)
    }
    public func didSelectContent(content: Any, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        didSelectContent(content as! ObjectType, at: indexPath, in: collectionView)
    }
    
    public func cellSize(for content: ObjectType, in collectionView: UICollectionView) -> CGSize {
        return cellSize
    }
    public func sectionInset(for content: ObjectType, in collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInset
    }
    public func minimumLineSpacing(for content: ObjectType, in collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacing
    }
    public func minimumInteritemSpacing(for content: ObjectType, in collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    public func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return cellSize(for: content as! ObjectType, in: collectionView)
    }
    public func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInset(for: content as! ObjectType, in: collectionView)
    }
    public func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacing(for: content as! ObjectType, in: collectionView)
    }
    public func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacing(for: content as! ObjectType, in: collectionView)
    }
}

extension TTCollectionCellController {
    var dataSource: TTDataSource? {
        return (self.parentViewController as? CollectionFeedController)?.dataSource
    }
    
    var dataSourceMutable: TTDataSourceMutable? {
        return dataSource as? TTDataSourceMutable
    }
}

extension UICollectionReusableView {
    private struct AssociatedKey {
        static var viewExtension = "viewExtension"
    }
    
    public var parentViewController : UIViewController? {
        get { return objc_getAssociatedObject(self, &AssociatedKey.viewExtension) as? UIViewController ?? nil }
        set { objc_setAssociatedObject(self, &AssociatedKey.viewExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN) }
    }
}