//
//  FeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 20/02/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

extension URLSessionTask: TTCancellable {
    
}


class TestViewController : UIViewController, CollectionController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadIndicatorView: UIActivityIndicatorView?
    @IBOutlet var emptyView: UIView?
    
    var cellController = ItemCellController()
    lazy var dataSource = DataSource<String>(loadPage: APIPaginateOffsetdSwiftMock.getResults(offset:callback:))
//    lazy var dataSource = DataSource(Example.allTest())
    var collectionController = CollectionFeedController()
    var forceTouchPreview: ForceTouchPreview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionController()
        collectionController.addPullToRefresh()
//        dataSource.insert("Maria", at: IndexPath(item: 0, section: 0))
//        let _ = dataSource[0].appending("2323 ")
        
        collectionController.cellsNibsAlreadyRegisteredInStoryboard(for: cellController)
//        collectionController.useAutoLayoutEstimatedSize = true
        collectionController.animatedUpdates = true
        forceTouchPreview = ForceTouchPreview(collectionController: collectionController, in: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

class ItemCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 400), reuseIdentifier: "TextCell")
        minimumInteritemSpacing = 10
        minimumLineSpacing = 20
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.subtitleLabel?.text = content
    }
    
    override func didSelectContent(_ content: String, at indexPath: IndexPath, in collectionView: UICollectionView) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestViewController")
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}


protocol CollectionController: class {
    associatedtype DataSourceType: TTDataSource
    associatedtype CellControllerType: TTAnyCollectionCellController
    associatedtype CollectionControllerType: CollectionFeedController
    
    var dataSource: DataSourceType {get set}
    var cellController: CellControllerType {get set}
    var collectionController: CollectionControllerType {get set}
    
    weak var collectionView: UICollectionView! {get set}
    
    weak var reloadIndicatorView: UIActivityIndicatorView? {get set}
    var emptyView: UIView? {get set} //set from XIB or overwrite
}

extension CollectionController where Self: UIViewController {
    func setupCollectionController() {
        collectionView?.dataSource = collectionController
        collectionView?.delegate = collectionController
        collectionController.reloadIndicatorView = reloadIndicatorView
        collectionController.collectionView = collectionView
        
        collectionController.cellController = cellController
        cellController.parentViewController = self
        collectionController.dataSource = dataSource
    }
}

