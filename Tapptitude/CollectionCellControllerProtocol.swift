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
    
    func classToInstantiateCellForContent(content: Any) -> AnyClass?
    func nibToInstantiateCellForContent(content: Any) -> UINib?
    
    func reuseIdentifierForContent(content: Any) -> String
    
    func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath)
    
    func didSelectContent(content: Any, indexPath: NSIndexPath, collectionView: UICollectionView)
    
    weak var parentViewController: UIViewController? { get set }
    
    var cellSize : CGSize { get }
    var sectionInset : UIEdgeInsets { get }
    var minimumLineSpacing : CGFloat { get }
    var minimumInteritemSpacing : CGFloat { get }
    
    func cellSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize
    func sectionInsetForContent(content: Any, collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat
}

// TODO: implement as option protocol
public protocol TTCollectionCellControllerProtocolExtended {
    func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath, dataSourceCount count: Int)
    func shouldHighlightContent(content: Any, atIndexPath indexPath: NSIndexPath) -> Bool
}

public protocol TTCollectionCellController : TTCollectionCellControllerProtocol {
    associatedtype ObjectType
    associatedtype CellType: UICollectionViewCell
    
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

public protocol TTCollectionCellControllerSize: TTCollectionCellController {
    var sizeCalculationCell: CellType! {get}
    
    func cellSizeToFitText(text: String, labelName: String, maxSize: CGSize) -> CGSize
    func cellSizeToFitText(text: String, labelName: String) -> CGSize // stretch height to max 2040 (label)
    
    func cellSizeToFitAttributedText(text: NSAttributedString, labelName: String, maxSize: CGSize) -> CGSize
    func cellSizeToFitAttributedText(text: NSAttributedString, labelName: String) -> CGSize
}

extension TTCollectionCellControllerSize {
    public func cellSizeToFitText(text: String, labelName: String, maxSize: CGSize) -> CGSize {
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
    
    public func cellSizeToFitText(text: String, labelName: String) -> CGSize { // stretch height to max 2040 (label)
        return cellSizeToFitText(text, labelName: labelName, maxSize: CGSizeMake(-1, 2040))
    }
    
    public func cellSizeToFitAttributedText(text: NSAttributedString, labelName: String, maxSize: CGSize) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        let label: UILabel = sizeCalculationCell.valueForKey(labelName) as! UILabel
        var maxSize = maxSize
        
        label.attributedText = text;
        
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
    
    public func cellSizeToFitAttributedText(text: NSAttributedString, labelName: String) -> CGSize {
        return cellSizeToFitAttributedText(text, labelName: labelName, maxSize: CGSizeMake(-1, 2040))
    }
}



extension TTCollectionCellController {
    public func acceptsContent(content: Any) -> Bool {
        return content is ObjectType
    }
    
    public func classToInstantiateCellForContent(content: ObjectType) -> AnyClass? {
        assert(CellType.self is UICollectionViewCell.Type)
        return CellType.self as? AnyClass
    }
    
    public func nibToInstantiateCellForContent(content: ObjectType) -> UINib? {
        let reuseIdentifier = reuseIdentifierForContent(content)
        if let _ = NSBundle.mainBundle().pathForResource(reuseIdentifier, ofType: "nib") {
            return UINib(nibName: reuseIdentifier, bundle: nil)
        } else {
            return nil
        }
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
    
    public func classToInstantiateCellForContent(content: Any) -> AnyClass? {
        return classToInstantiateCellForContent(content as! ObjectType)
    }
    public func nibToInstantiateCellForContent(content: Any) -> UINib? {
        return nibToInstantiateCellForContent(content as! ObjectType)
    }
    public func reuseIdentifierForContent(content: Any) -> String {
        return reuseIdentifierForContent(content as! ObjectType)
    }
    public func configureCell(cell: UICollectionViewCell, forContent content: Any, indexPath: NSIndexPath) {
        configureCell(cell as! CellType, forContent: content as! ObjectType, indexPath: indexPath)
    }
    public func didSelectContent(content: Any, indexPath: NSIndexPath, collectionView: UICollectionView) {
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
    
    public func cellSizeForContent(content: Any, collectionView: UICollectionView) -> CGSize {
        return cellSizeForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func sectionInsetForContent(content: Any, collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInsetForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func minimumLineSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacingForContent(content as! ObjectType, collectionView: collectionView)
    }
    public func minimumInteritemSpacingForContent(content: Any, collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacingForContent(content as! ObjectType, collectionView: collectionView)
    }
}

extension UICollectionViewCell {
    private struct AssociatedKey {
        static var viewExtension = "viewExtension"
    }
    
    public var parentViewController : UIViewController? {
        get { return objc_getAssociatedObject(self, &AssociatedKey.viewExtension) as? UIViewController ?? nil }
        set { objc_setAssociatedObject(self, &AssociatedKey.viewExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN) }
    }
}