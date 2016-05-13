//: [Previous](@previous)

import UIKit
import Tapptitude

class SwipeCell : TextCell, SwipeToEditCell {
    var containerView : UIView!
    var rightView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView = UIView(frame: bounds)
        containerView.addSubview(label)
        containerView.backgroundColor = .lightGrayColor()
        
        let rightFrame = CGRect(x: frame.width - 50, y: 0, width: 50, height: frame.height)
        rightView = UIView(frame: rightFrame)
        rightView.autoresizingMask = [.FlexibleLeftMargin]
        rightView.backgroundColor = .redColor()
        
        contentView.addSubview(rightView)
        contentView.addSubview(containerView)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTranslate(transform: CGAffineTransform, translationPercentInsets: UIEdgeInsets) {
    }
    
    func shouldStartSwipe() -> Bool {
        return true
    }
    
    override func prepareForReuse() {
        self.containerView.transform = CGAffineTransformIdentity
    }
}

class SwipeController: CollectionFeedController, SwipeToEditOnCollection {
    var panGestureRecognizer : SwipeToEditGesture?
    var tapGestureRecognizer : TouchRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSwipeToEdit()
    }
}


let items = NSArray(arrayLiteral: "Maria", "232")
let dataSource = DataSource(items)

class TextCellController: CollectionCellController<String, SwipeCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 5
    }
    
    override func configureCell(cell: SwipeCell, forContent content: String, indexPath: NSIndexPath) {
        cell.label.text = content
    }
    
    override func didSelectContent(content: String, indexPath: NSIndexPath, collectionView: UICollectionView) {
        print("did select", content)
    }
}



let feedController = SwipeController(nibName: "CollectionFeedController", bundle: nil)
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view

//: [Next](@next)
