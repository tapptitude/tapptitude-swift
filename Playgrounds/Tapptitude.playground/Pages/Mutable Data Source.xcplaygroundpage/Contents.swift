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
        
        self.cellController = cellController
        self.dataSource = DataSource([1, 2])
    }
    
    var dataSourceMutable: DataSource<Int> {
        return dataSource as! DataSource<Int>
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        
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
        for _ in 1...5 {
            counter += 1
            self.plusAction(self);
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size: CGSize = dataSource!.hasContent() == true ? CGSize(width: 0, height: 30) : CGSize.zero
        return size
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "test", for: indexPath);
            header.backgroundColor = UIColor.darkGray;
            return header;
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
}

let editController = EditViewController()
import PlaygroundSupport
PlaygroundPage.current.liveView = editController.view


//: [Next](@next)
