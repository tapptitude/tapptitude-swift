//: Playground - noun: a place where people can play

import UIKit
import Tapptitude
import NDetailSlideshow
import XCPlayground

extension UIImage: ImageResource {
    public var image:UIImage {
        get {
            return self
        }
    }
}


let viewController = CollectionFeedController()
let view = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 667))
viewController.view = view

viewController.view.backgroundColor = UIColor.whiteColor()
    
viewController.cellController = NDetailSlideshowCellController()
let images: [UIImage] = [ UIImage(named: "red.jpg")!,UIImage(named: "yellow.jpg")!,UIImage(named: "blue.jpg")!]


let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 350, height: 667), collectionViewLayout: UICollectionViewFlowLayout())
viewController.collectionView = collectionView
viewController.dataSource = DataSource(images.map({ $0 as Any}))
viewController.view.addSubview(collectionView)

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 350, height: 667))
window.rootViewController = viewController
window.makeKeyAndVisible()
XCPlaygroundPage.currentPage.liveView = window

