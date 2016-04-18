//: [Previous](@previous)

import UIKit
import Tapptitude
import XCPlayground

var counter = 3;

class EditViewController: CollectionFeedController {
    
    convenience init() {
        self.init(nibName: "EditViewController", bundle: nil);
        
        let cellController = CollectionCellController<Int, TextCell>(cellSize: CGSize(width:60, height:60))
        cellController.minimumLineSpacing = 20
        cellController.minimumInteritemSpacing = 20
        cellController.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cellController.configureCell = { cell, content, indexPath in
            cell.label.text = "\(content)"
        }
        
        self.cellController = cellController
        self.dataSource = DataSource([1, 2])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        
        animatedUpdates = true
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
        for _ in 1...5 {
            counter += 1
            self.plusAction(self);
        }
    }
    
    @IBAction func minusMoreAction(sender: AnyObject) {
        for _ in 1...5 {
            self.minusAction(self);
        }
    }
    
    @IBAction func appendAction(sender: AnyObject) {
        var content = [Int]()
        for _ in 1...5 {
            counter += 1
            content.append(counter)
        }
        
        dataSourceMutable?.addContentFromArray(content.convertTo())
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
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size: CGSize = dataSource!.hasContent() == true ? CGSizeMake(0, 30) : CGSizeZero
        return size
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "test", forIndexPath: indexPath);
            header.backgroundColor = UIColor.darkGrayColor();
            return header;
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        }
    }
}

let editController = EditViewController()
XCPlaygroundPage.currentPage.liveView = editController.view


//: [Next](@next)
