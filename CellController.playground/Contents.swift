//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

public protocol TTCollectionCellController {
    typealias ObjectType
    typealias CellType
    
    func acceptsContent(content: AnyObject) -> Bool
    
    func classToInstantiateCellForContent(content: ObjectType) -> AnyClass?
    func nibToInstantiateCellForContent(content: ObjectType) -> UINib?

    func reuseIdentifierForContent(content: ObjectType) -> String
    
    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath)

    func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView)

    var parentViewController: UIViewController? { get set }
    
//    func cellSizeForContent(content: ObjectType, collectionView: UICollectionView) -> CGSize
//    
    var cellSize : CGSize { get }
    var sectionInset : UIEdgeInsets { get }
    var minimumLineSpacing : CGFloat { get }
    var minimumInteritemSpacing : CGFloat { get }

//
//    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath, dataSourceCount count: Int)
//    
//    func shouldHighlightContent(content: ObjectType, atIndexPath indexPath: NSIndexPath) -> Bool
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
    func acceptsContent(content: AnyObject) -> Bool {
        return content is ObjectType
    }
    
    func classToInstantiateCellForContent(content: ObjectType) -> AnyClass? {
        if let classType = CellType.self as? AnyClass {
            return classType
        } else {
            return nil
        }
    }
    
    func nibToInstantiateCellForContent(content: ObjectType) -> UINib? {
        return UINib(nibName: String(CellType), bundle: nil)
    }
    
    func reuseIdentifierForContent(content: ObjectType) -> String {
        return String(CellType)
    }
    
    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath) {
        
    }
    
    func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) {
        
    }

    // sizes
    var sectionInset : UIEdgeInsets { return UIEdgeInsetsZero }
    var minimumLineSpacing : CGFloat { return 0.0 }
    var minimumInteritemSpacing : CGFloat { return 0.0 }
    var cellSize : CGSize { return CGSizeZero }
}

class TestCell : UICollectionViewCell {
    var testLabel: UILabel!
}

class AnotherTestCell : UICollectionViewCell {
    var imageView : UIImageView!
}

class SimpleCellController<ObjectClass, CellName> : TTCollectionCellController {
    typealias ObjectType = ObjectClass
    typealias CellType = CellName
    
    var didSelectContentBlock : ((content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) -> Void)?
    var configureCellBlock : ((cell: CellType, content: ObjectType, indexPath: NSIndexPath) -> Void)?
    
    func didSelectContent(content: ObjectType, indexPath: NSIndexPath, collectionView: UICollectionView) {
        didSelectContentBlock?(content: content, indexPath: indexPath, collectionView: collectionView)
    }
    
    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath) {
        configureCellBlock?(cell: cell, content: content, indexPath: indexPath)
    }
    
    var sectionInset = UIEdgeInsetsZero
    var minimumLineSpacing = 0.0
    var minimumInteritemSpacing = 0.0
    var cellSize : CGSize!
    
    var parentViewController : UIViewController?
    
    init(cellSize : CGSize = CGSizeZero) {
        self.cellSize = cellSize
    }
}

class TestCellController : TTCollectionCellController {
    typealias ObjectType = String
    typealias CellType = TestCell

    var parentViewController : UIViewController?
    
    func configureCell(cell: CellType, forContent content: ObjectType, indexPath: NSIndexPath) {
        cell.testLabel.text = content
    }
}

let item = TestCellController()
item.acceptsContent("maria")
item.classToInstantiateCellForContent("test")
item.reuseIdentifierForContent("2")
item.sectionInset.bottom
item.minimumInteritemSpacing
item.minimumLineSpacing

let generic = SimpleCellController<Int, AnotherTestCell>(cellSize: CGSize(width: 23, height: 23))
generic.acceptsContent("123")
generic.acceptsContent(1)
generic.reuseIdentifierForContent(2)
generic.cellSize
generic.configureCellBlock = { cell, content, indexPath in
    print(indexPath.row)
    print(content)
}
generic.configureCell(AnotherTestCell(), forContent: 123, indexPath: NSIndexPath(forRow: 1, inSection: 0))



