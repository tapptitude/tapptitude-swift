//
//  ParallelFeedController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 08/12/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class ParallelFeedController: CollectionFeedController {
    override func viewDidLoad() {
        let dataSource = DataSource<Any>()
        dataSource.addOperation(load: API.getBin)
        dataSource.addOperation(load: API.getHackerNews)
        self.dataSource = dataSource
        
        self.cellController = TextItemCellController()
    }
}


class TextItemCellController: CollectionCellController<String, TextCell> {
    init() {
        super.init(cellSize: CGSize(width: -1, height: 50))
        minimumInteritemSpacing = 10
        minimumLineSpacing = 20
        sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    }
    
    override func configureCell(_ cell: TextCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.backgroundColor = .brown
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, labelName: "label" , maxSize: CGSize(width:-1, height:500))
        size.height = min(size.height, 500)
        return size
    }
}





class API {
    static func getBin(callback: @escaping (_ items: [String]?, _ error: Error?) -> ()) -> TTCancellable? {
        let url = URL(string: "https://httpbin.org/get")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error)
            
            DispatchQueue.main.async {
                callback(items, error)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNews(callback: @escaping (_ items: [String]?, _ error: Error?) -> ()) -> TTCancellable? {
        let url = URL(string: "https://news.ycombinator.com/news")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error)
            
            DispatchQueue.main.async {
                callback(items, error)
            }
        }
        task.resume()
        
        return task
    }
}

