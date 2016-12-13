//: [Previous](@previous)

import UIKit
import Tapptitude


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
        
        let headerController = CollectionHeaderController<Int, UICollectionReusableView>(headerSize: CGSize(width: 0, height: 30))
        headerController.configureHeader = {(header, _, _) in
            header.backgroundColor = UIColor.darkGray
        }
        self.headerController = headerController
        
        self.cellController = cellController
        self.dataSource = DataSource([1, 2])
    }
    
    var dataSourceMutable: DataSource<Int> {
        return dataSource as! DataSource<Int>
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animatedUpdates = true
    }
    
    @IBAction func plusAction(_ sender: AnyObject) {
        let pos = min(1, dataSource!.numberOfItems(inSection: 0))
        dataSourceMutable.insert(counter, at: IndexPath(item: pos, section: 0))
        counter += 1
    }
    
    @IBAction func minusAction(_ sender: AnyObject) {
        if dataSource!.numberOfItems(inSection: 0) > 0 {
            dataSourceMutable.remove(at: IndexPath(item: 0, section: 0))
        }
    }
    
    @IBAction func plusMoreAction(_ sender: AnyObject) {
//        for _ in 1...5 {
//            counter += 1
//            self.plusAction(self);
//        }
        
        let content = [Int](counter...counter+400)
        let position = dataSourceMutable.count
        dataSourceMutable.insert(contentsOf: content, at: IndexPath(item: position, section: 0))
        counter += 5
    }
    
    @IBAction func minusMoreAction(_ sender: AnyObject) {
        for _ in 1...5 {
            self.minusAction(self);
        }
    }
    
    @IBAction func appendAction(_ sender: AnyObject) {
        var content = [Int]()
        for _ in 1...5 {
            counter += 1
            content.append(counter)
        }
        
        dataSourceMutable.append(contentsOf: content)
    }
    
    @IBAction func moveAction(_ sender: AnyObject) {
        if dataSource!.numberOfItems(inSection: 0) < 2 {
            return
        }
        
        let fromIndexPath = IndexPath(item: collectionView!.numberOfItems(inSection: 0) - 1, section: 0)
        let toIndexPath = IndexPath(item:0, section:0)
        print("from \(fromIndexPath.row) to \(toIndexPath.row)")
        dataSourceMutable.moveElement(from: fromIndexPath, to: toIndexPath)
    }
}

let editController = EditViewController()
import PlaygroundSupport
PlaygroundPage.current.liveView = editController.view


//: [Next](@next)
