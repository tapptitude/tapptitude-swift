//: [Previous](@previous)

import UIKit
import Tapptitude
import XCPlayground

class TextCell : UICollectionViewCell {
    var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.textColor = UIColor.blackColor()
        label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        label.textAlignment = .Center
        addSubview(label)
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

var counter = 3;

class EditViewController: CollectionFeedController {
    var dataSourceMutable: TTDataSourceMutable? {
        return dataSource as? TTDataSourceMutable
    }
    
    convenience init() {
        self.init(nibName: "EditViewController", bundle: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellController = CollectionCellController<Int, TextCell>(cellSize: CGSize(width:60, height:60))
//        cellController.minimumLineSpacing = 5
//        cellController.minimumInteritemSpacing = 5
//        cellController.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cellController.configureCell = { cell, content, indexPath in
            cell.label.text = "\(content)"
        }
        
        self.cellController = cellController
        self.dataSource = DataSource(content:[1, 2])
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    @IBAction func plusAction(sender: AnyObject) {
        let pos = min(1, dataSource!.numberOfRowsInSection(0))
        dataSourceMutable?.insertContent(counter, atIndexPath: NSIndexPath(forItem: pos, inSection: 0))
        counter += 1
    }
    
    @IBAction func minusAction(sender: AnyObject) {
        if dataSource!.numberOfRowsInSection(0) > 0 {
            dataSourceMutable?.removeContentFromIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        }
    }
    
    @IBAction func plusMoreAction(sender: AnyObject) {
        let content = NSMutableArray();
        for _ in 1...5 {
            counter += 1
            content.addObject(counter);
        }
        
        for _ in 1...5 {
            self.plusAction(self);
        }
    }
    
    @IBAction func minusMoreAction(sender: AnyObject) {
        for _ in 1...5 {
            self.minusAction(self);
        }
    }
    
    @IBAction func appendAction(sender: AnyObject) {
        let content = NSMutableArray();
        for _ in 1...5 {
            counter += 1
            content.addObject(counter);
        }
        
        dataSourceMutable?.addContentFromArray(content as [AnyObject])
    }
    
    @IBAction func moveAction(sender: AnyObject) {
        if dataSource!.numberOfRowsInSection(0) < 2 {
            return
        }
        
        let fromIndexPath = NSIndexPath(forItem: collectionView!.numberOfItemsInSection(0) - 1, inSection: 0)
        let toIndexPath = NSIndexPath(forItem:0, inSection:0)
        print("from \(fromIndexPath.row) to \(toIndexPath.row)")
        dataSourceMutable?.moveContentFromIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
    
    //    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    //        return self.dataSource.hasContent() ? CGSizeMake(self.collectionView!.bounds.size.width, 30) : CGSizeZero;
    //    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "test", forIndexPath: indexPath);
        header.backgroundColor = UIColor.darkGrayColor();
        return header;
    }
}

let editController = EditViewController()
XCPlaygroundPage.currentPage.liveView = editController.view


//: [Next](@next)
