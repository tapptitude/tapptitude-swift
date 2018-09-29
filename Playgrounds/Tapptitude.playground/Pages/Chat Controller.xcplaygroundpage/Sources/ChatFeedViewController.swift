import UIKit
import Tapptitude

public class ChatFeedViewController : __CollectionFeedController {
    @IBOutlet var inputContainerView: ChatInputContainerView!
    
    var dataSource: DataSource<String>! {
        didSet { _dataSource = dataSource }
    }
    var cellController: TextCellController! {
        didSet { _cellController = cellController }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        inputContainerView.removeFromSuperview()
        
        let keyboard = self.collectionView?.addKeyboardVisibilityController()
        keyboard?.dismissKeyboardTouchRecognizer = nil
        
        let dataSource = DataSource<String>()
//        let dataSource = SectionedDataSource<String>([["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]])
//        let dataSource = SectionedDataSource<String>([[]])
        
        self.cellController = TextCellController()
        let header = CollectionHeaderController<[String], UICollectionViewCell>(headerSize: CGSize(width: 20, height: 40))
        header.configureHeader = { (header: UICollectionViewCell, content: [String], indexPath) in
            header.backgroundColor = .red
        }
        self.headerController = header
        self.dataSource = dataSource
        animatedUpdates = true
    }
    
    @IBAction func sendAction(_ sender: AnyObject) {
        dataSource.append(inputContainerView.text)
        let indexPath = dataSource.lastIndexPath!
        inputContainerView.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override var inputAccessoryView: UIView? {
        return inputContainerView
    }
}
