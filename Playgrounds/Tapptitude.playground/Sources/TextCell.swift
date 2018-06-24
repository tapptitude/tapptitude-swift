import UIKit

open class TextCell : UICollectionViewCell {
    open var label: UILabel!
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)))
        label.textColor = UIColor.black
        label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import Tapptitude

open class TextCellController : CollectionCellController<String, TextCell> {
    public init() {
        super.init(cellSize: CGSize(width: 50, height: 50))
        
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom:10, right: 0)
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
    }
    
    public init(cellSize : CGSize) {
        super.init(cellSize: cellSize)
    }
    
    open override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 0.9, alpha: 1)
        cell.label.text = content
        cell.label.textColor = UIColor.black
    }
    
    open override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        return cellSizeToFit(text:content, label:  sizeCalculationCell.label , maxSize: CGSize(width: 300, height: -1))
    }
    
    open override func didSelectContent(_ content: String, at indexPath: IndexPath, in collectionView: UICollectionView) {
        print("did select", content)
    }
}


open class BrownTextCellController: CollectionCellController<String, TextCell> {
    public init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 10
        minimumLineSpacing = 20
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    override open func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.backgroundColor = .brown
        cell.label.textColor = UIColor.black
    }
    
    override open func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, label: sizeCalculationCell.label , maxSize: CGSize(width:-1, height:500))
        size.height = min(size.height, 500)
        return size
    }
}



open class IntCellController : CollectionCellController<Int, TextCell> {
    public init() {
        super.init(cellSize: CGSize(width: 50, height: 50))
        
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        minimumInteritemSpacing = 10
    }
    
    public init(cellSize : CGSize) {
        super.init(cellSize: cellSize)
    }
    
    open override func configureCell(_ cell: TextCell, for content: Int, at indexPath: IndexPath) {
        cell.label.text = String(content)
        cell.label.textColor = UIColor.brown
    }
    
    open override func didSelectContent(_ content: Int, at indexPath: IndexPath, in collectionView: UICollectionView) {
        print("did select", content)
    }
}



open class IntHeaderCellController : CollectionHeaderController<[Int], TextCell> {
    public init() {
        super.init(headerSize: CGSize(width: 30, height: 50))
    }
    
    open override func configureHeader(_ header: TextCell, for content: [Int], at indexPath: IndexPath) {
        header.label.text = content.map({ String($0) }).joined(separator: ", ")
        header.label.textColor = .white
    }
}


open class StringHeaderCellController : CollectionHeaderController<[String], TextCell> {
    public init() {
        super.init(headerSize: CGSize(width: 30, height: 20))
    }
    
    open override func configureHeader(_ header: TextCell, for content: [String], at indexPath: IndexPath) {
        header.label.text = content.joined(separator: ", ")
        header.label.textColor = .gray
    }
}






