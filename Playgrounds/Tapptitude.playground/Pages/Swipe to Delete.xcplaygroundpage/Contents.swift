//: [Previous](@previous)

import UIKit
import Tapptitude

class SwipeCell : TextCell, SwipeToEditCell {
    var containerView : UIView!
    var rightView : UIView!
    
    var item: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView = UIView(frame: bounds)
        containerView.addSubview(label)
        containerView.backgroundColor = .lightGrayColor()
        
        let rightFrame = CGRect(x: frame.width - 70, y: 0, width: 70, height: frame.height)
        let button = UIButton(frame: rightFrame)
        button.setTitle("Delete", forState: .Normal)
        button.addTarget(self, action: #selector(SwipeCell.deleteAction(_:)), forControlEvents: .TouchUpInside)
        button.autoresizingMask = [.FlexibleLeftMargin]
        button.backgroundColor = .redColor()
        
        rightView = button
        contentView.addSubview(rightView)
        contentView.addSubview(containerView)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        guard let parentViewController = parentViewController else {
            return
        }
        
        let controller = parentViewController as! CollectionFeedController
        let indexPath = controller.collectionView!.indexPathForCell(self)
        let dataSource = controller.dataSource as! DataSource
        dataSource.remove(at: indexPath!)
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


let items = NSArray(arrayLiteral: "Maria", "232", "Ghita", "Ion")
let dataSource = DataSource(items)

class TextCellController: CollectionCellController<String, SwipeCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 5
    }
    
    override func configureCell(cell: SwipeCell, for content: String, at indexPath: NSIndexPath) {
        cell.label.text = content
        cell.item = content
    }
    
    override func didSelectContent(content: String, at indexPath: NSIndexPath, in collectionView: UICollectionView) {
        print("did select", content)
    }
}



let feedController = SwipeController(nibName: "CollectionFeedController", bundle: nil)
feedController.dataSource = dataSource
feedController.cellController = TextCellController()

import XCPlayground
XCPlaygroundPage.currentPage.liveView = feedController.view

//: [Next](@next)
