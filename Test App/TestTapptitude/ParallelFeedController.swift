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
        super.viewDidLoad()
        
        let dataSource = DataSource<Any>()
//        dataSource.addOperation(load: API.getBin)
//        dataSource.addOperation(load: API.getHackerNews)
        
        let feed = ParallelDataFeed()
        feed.reloadOperation.append(operation: API.getBin)
        feed.reloadOperation.append(operation: API.getHackerNews(page:callback:))
        
        feed.loadMoreOperation.append(operation: API.getHackerNews(page:callback:))
        dataSource.feed = feed
        
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
    }
    
    override func cellSize(for content: String, in collectionView: UICollectionView) -> CGSize {
        var size = cellSizeToFit(text: content, label: sizeCalculationCell.label, maxSize: CGSize(width:-1, height:500))
        size.height = min(size.height, 500)
        return size
    }
}





class API {
    static func getBin(callback: @escaping TTCallback<[String]>) -> TTCancellable? {
        let url = URL(string: "https://httpbin.org/get")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error)
            let result: Result<[String]> = error != nil ? .failure(error!) : .success(items ?? [])
            
            DispatchQueue.main.async {
                callback(result)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNews1(callback: @escaping (_ result: Result<[String]>) -> ()) -> TTCancellable? {
        let url = URL(string: "https://news.ycombinator.com/news")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error)
            let result: Result<[String]> = error != nil ? .failure(error!) : .success(items ?? [])
            
            DispatchQueue.main.async {
                callback(result)
            }
        }
        task.resume()
        
        return task
    }
    
    static func getHackerNews(page: Int?, callback: @escaping TTCallback<([String], Int?)>) -> TTCancellable? {
        let newPage = page ?? 0
        let url = URL(string: "https://news.ycombinator.com/news?p=\(newPage)")
        let url_request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: url_request) { data , response , error  in
            let stringResponse = data != nil ? String(data: data!, encoding: String.Encoding.utf8) : nil
            let items: [String]? = stringResponse != nil ? [stringResponse!] : nil
            print(error ?? "")
            
            let nextPage = items?.isEmpty == false ? (newPage + 1) : nil
            let result: Result<([String], Int?)> = error != nil ? .failure(error!) : .success((items!, nextPage))
            
            DispatchQueue.main.async {
                callback(result)
            }
        }
        task.resume()
        
        return task
    }
}

