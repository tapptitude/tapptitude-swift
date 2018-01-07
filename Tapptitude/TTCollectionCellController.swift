//
//  CellController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 17/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

public protocol TTAnyCollectionCellController: class {
    func acceptsContent(_ content: Any) -> Bool
    
    func classToInstantiateCell(for content: Any) -> AnyClass?
    func nibToInstantiateCell(for content: Any) -> UINib?
    
    func reuseIdentifier(for content: Any) -> String
    
    func configureCell(_ cell: UICollectionViewCell, for content: Any, at indexPath: IndexPath)
    
    func didSelectContent(_ content: Any, at indexPath: IndexPath, in collectionView: UICollectionView)
    
    weak var parentViewController: UIViewController? { get set }
    
    var cellSize : CGSize { get }
    var sectionInset : UIEdgeInsets { get }
    var minimumLineSpacing : CGFloat { get }
    var minimumInteritemSpacing : CGFloat { get }
    
    func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize
    func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat
    
    /// should expose all reuse identifiers that this cellController can configure
    func allSupportedReuseIdentifiers() -> [String]
}

extension TTCollectionCellController {
    public var dataSource: TTAnyDataSource? {
        return (self.parentViewController as? TTCollectionFeedController)?._dataSource
    }
}


public protocol TTCollectionCellController : TTAnyCollectionCellController {
    associatedtype ContentType
    associatedtype CellType: UICollectionViewCell
    
    func classToInstantiateCell(for content: ContentType) -> AnyClass?
    func nibToInstantiateCell(for content: ContentType) -> UINib?
    
    func reuseIdentifier(for content: ContentType) -> String
    
    func configureCell(_ cell: CellType, for content: ContentType, at indexPath: IndexPath)
    
    func didSelectContent(_ content: ContentType, at indexPath: IndexPath, in collectionView: UICollectionView)
    
    func cellSize(for content: ContentType, in collectionView: UICollectionView) -> CGSize
    func sectionInset(for content: ContentType, in collectionView: UICollectionView) -> UIEdgeInsets
    func minimumLineSpacing(for content: ContentType, in collectionView: UICollectionView) -> CGFloat
    func minimumInteritemSpacing(for content: ContentType, in collectionView: UICollectionView) -> CGFloat
}

public protocol TTCollectionCellControllerSize: TTCollectionCellController {
    var sizeCalculationCell: CellType! {get}
    
    /// pass label from sizeCalculationCell. Ex: sizeCalculationCell.label
    func cellSizeToFit(text: String, label: UILabel, maxSize: CGSize) -> CGSize
    func cellSizeToFit(attributedText: NSAttributedString, label: UILabel, maxSize: CGSize) -> CGSize
}





extension TTCollectionCellControllerSize {
    /// returns cell size to fit text by using sizeCalculationCell property
    /// - parameter label: Ex: sizeCalculationCell.textLabel
    public func cellSizeToFit(text: String, label: UILabel, maxSize: CGSize = CGSize(width: -1, height: 2040)) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        var maxSize = maxSize
        
        label.text = text;
        
        if (maxSize.width < 0) {
            assert(label.lineBreakMode == .byWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
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
    
    public func cellSizeToFit(attributedText: NSAttributedString, label: UILabel, maxSize: CGSize = CGSize(width: -1, height: 2040)) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        var maxSize = maxSize
        
        label.attributedText = attributedText;
        
        if (maxSize.width < 0) {
            assert(label.lineBreakMode == .byWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
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
            assert(label.lineBreakMode == .byWordWrapping, "Label line break mode should be NSLineBreakByWordWrapping")
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
    
    public func cellSizeToFit(attributedText: NSAttributedString, textView: UITextView, maxSize: CGSize = CGSize(width: -1, height: 2040)) -> CGSize {
        var size = sizeCalculationCell.bounds.size
        var maxSize = maxSize
        
        textView.attributedText = attributedText;
        
        if (maxSize.width < 0) {
            maxSize.width = textView.bounds.size.width
            let newLabelSize = textView.sizeThatFits(maxSize)
            size.height += newLabelSize.height - textView.bounds.size.height
            size.width = cellSize.width
        } else if (maxSize.height < 0) {
            maxSize.height = textView.bounds.size.height
            let newLabelSize = textView.sizeThatFits(maxSize)
            size.width += newLabelSize.width - textView.bounds.size.width
            size.height = cellSize.height;
        } else {
            var frame = sizeCalculationCell.frame
            frame.size.width = maxSize.width
            sizeCalculationCell.frame = frame
            self.sizeCalculationCell.layoutSubviews()
            maxSize.width = textView.bounds.size.width
            let newLabelSize = textView.sizeThatFits(maxSize)
            size.height += newLabelSize.height - textView.bounds.size.height
            size.width = cellSize.width
        }
        
        return size;
    }
}



extension TTCollectionCellController {
    public func classToInstantiateCell(for content: Any) -> AnyClass? {
        return classToInstantiateCell(for: content as! ContentType)
    }
    public func nibToInstantiateCell(for content: Any) -> UINib? {
        return nibToInstantiateCell(for: content as! ContentType)
    }
    public func reuseIdentifier(for content: Any) -> String {
        return reuseIdentifier(for: content as! ContentType)
    }
    public func configureCell(_ cell: UICollectionViewCell, for content: Any, at indexPath: IndexPath) {
        configureCell(cell as! CellType, for: content as! ContentType, at: indexPath)
    }
    public func didSelectContent(_ content: Any, at indexPath: IndexPath, in collectionView: UICollectionView) {
        didSelectContent(content as! ContentType, at: indexPath, in: collectionView)
    }
    
    public func cellSize(for content: Any, in collectionView: UICollectionView) -> CGSize {
        return cellSize(for: content as! ContentType, in: collectionView)
    }
    public func sectionInset(for content: Any, in collectionView: UICollectionView) -> UIEdgeInsets {
        return sectionInset(for: content as! ContentType, in: collectionView)
    }
    public func minimumLineSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return minimumLineSpacing(for: content as! ContentType, in: collectionView)
    }
    public func minimumInteritemSpacing(for content: Any, in collectionView: UICollectionView) -> CGFloat {
        return minimumInteritemSpacing(for: content as! ContentType, in: collectionView)
    }
}

extension UICollectionReusableView {
    fileprivate struct AssociatedKey {
        static var viewExtension = "viewExtension"
    }
    
    public var parentViewController : UIViewController? {
        get { return objc_getAssociatedObject(self, &AssociatedKey.viewExtension) as? UIViewController ?? nil }
        set { objc_setAssociatedObject(self, &AssociatedKey.viewExtension, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN) }
    }
}
