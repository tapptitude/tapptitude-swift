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
        containerView.backgroundColor = .lightGray
        
        let rightFrame = CGRect(x: frame.width - 70, y: 0, width: 70, height: frame.height)
        let button = UIButton(frame: rightFrame)
        button.setTitle("Delete", for: .normal)
        button.addTarget(self, action: #selector(SwipeCell.deleteAction(sender:)), for: .touchUpInside)
        button.autoresizingMask = [.flexibleLeftMargin]
        button.backgroundColor = .red
        
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
        let indexPath = controller.collectionView!.indexPath(for:self)
        let dataSource = controller.dataSource as! DataSource<String>
        dataSource.remove(at: indexPath!)
    }
    
    func didTranslate(_ transform: CGAffineTransform, translationPercentInsets: UIEdgeInsets) {
    }
    
    func shouldStartSwipe() -> Bool {
        return true
    }
    
    override func prepareForReuse() {
        self.containerView.transform = .identity
    }
}

class SwipeController: CollectionFeedController, SwipeToEditOnCollection {
    var panGestureRecognizer : PanViewGestureRecognizer?
    var tapGestureRecognizer : TouchRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSwipeToEdit()
    }
}


let items = NSArray(arrayLiteral: "Maria", "232", "Ghita", "Ion")
let dataSource = DataSource<String>(items)

class TextCellController: CollectionCellController<String, SwipeCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 20
        minimumLineSpacing = 5
    }
    
    override func configureCell(_ cell: SwipeCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.item = content
    }
    
    override func didSelectContent(_ content: String, at indexPath: IndexPath, in collectionView: UICollectionView) {
        print("did select", content)
    }
}



let feedController = SwipeController()
feedController.dataSource = dataSource
feedController.cellController = TextCellController()
feedController.animatedUpdates = true

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
