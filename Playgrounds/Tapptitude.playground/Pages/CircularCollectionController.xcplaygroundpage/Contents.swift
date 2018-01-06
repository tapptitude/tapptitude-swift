//: [Previous](@previous)

import Tapptitude
import UIKit
import PlaygroundSupport

class CircularCollectionController: CollectionFeedController {
    
    var sliderTimeInterval = 3.0 { // 0 to disable it
        didSet {
            if oldValue != sliderTimeInterval {
                configureTimer()
            }
        }
    }
    var content: [Any] = [] {
        didSet {
            pageControl?.numberOfPages = content.count
            pageControl?.isHidden = content.count < 2
            
            var circularContent = content
            if circularContent.count > 1 {
                circularContent.append(content.first!)
                circularContent.insert(content.last!, at: 0)
            }
            self.dataSource = DataSource(circularContent)
            
            if circularContent.count > 1 {
                if collectionView?.window == nil {
                    toDisplayPage = 0
                } else {
                    displayedPage = 0
                    configureTimer()
                }
            }
        }
    }
    private var toDisplayPage: Int = -1 //ingore
    
    @IBOutlet weak var pageControl: UIPageControl?
    
    var userDidScroll = false
    var displayedPage: Int {
        get {
            let pageWidth = collectionView!.bounds.size.width
            let page = Int(floor((collectionView!.contentOffset.x / pageWidth)))
            let itemsCount = content.count
            if itemsCount > 1 {
                return page == 0 ? (itemsCount - 1) : (page == itemsCount + 1 ? 0 : page - 1)
            } else {
                return 0
            }
        }
        set {
            pageControl?.currentPage = newValue
            let item = newValue + (content.count > 1 ? 1 : 0)
            let indexPath = IndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    var lastContentOffsetX = CGFloat.leastNonzeroMagnitude
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let count = dataSource!.content.count
        if count < 2 {
            return
        }
        
        // We can ignore the first time scroll,
        // because it is caused by the call scrollToItemAtIndexPath: in ViewWillAppear
        if (CGFloat.leastNonzeroMagnitude == lastContentOffsetX) {
            lastContentOffsetX = scrollView.contentOffset.x
            return;
        }
        
        let currentOffsetX = scrollView.contentOffset.x
        let currentOffsetY = scrollView.contentOffset.y
        
        let pageWidth = scrollView.bounds.size.width
        let offset = pageWidth * CGFloat(count - 2)
        
        // the first page(showing the last item) is visible and user's finger is still scrolling to the right
        if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
            lastContentOffsetX = currentOffsetX + offset;
            scrollView.contentOffset = CGPoint(x: lastContentOffsetX, y: currentOffsetY)
        }
            // the last page (showing the first item) is visible and the user's finger is still scrolling to the left
        else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
            lastContentOffsetX = currentOffsetX - offset;
            scrollView.contentOffset = CGPoint(x: lastContentOffsetX, y: currentOffsetY)
        } else {
            lastContentOffsetX = currentOffsetX;
        }
        
        pageControl?.currentPage = displayedPage
        
//        let collectionView = self.collectionView!
//        // Calculate where the collection view should be at the right-hand end item
//        let count = dataSource!.content.count
//        let contentOffsetWhenFullyScrolledRight = collectionView.frame.width * (CGFloat(count - 1))
//
//        if scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight {
//
//            // user is scrolling to the right from the last item to the 'fake' item 1.
//            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
//
//            let indexPath = IndexPath(item: 1, section: 0)
//
//            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
//        } else if scrollView.contentOffset.x == 0  {
//
//            // user is scrolling to the left from the first item to the fake 'item N'.
//            // reposition offset to show the 'real' item N at the right end end of the collection view
//
//            let indexPath = IndexPath(item: count - 2, section: 0)
//            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
//        }
    }
    
    @objc func scrollToNextPageAnimated() {
        if let visibleIndex = collectionView?.indexPathsForVisibleItems.first {
            var currentPage = visibleIndex.row + 1
            if currentPage >= dataSource?.numberOfItems(inSection: 0) ?? Int.max {
                currentPage = 1
            }
            
            let index = IndexPath(item: currentPage, section: 0)
            collectionView?.scrollToItem(at: index, at: .right, animated: true)
        }
        
        configureTimer()
    }
    
    var timer: Timer!
    
    deinit {
        timer?.invalidate()
    }
    
    func configureTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        if content.count > 1 && !userDidScroll && sliderTimeInterval > 0.0 {
            animateProgressBar()
            
            timer = Timer(timeInterval: sliderTimeInterval, target: self, selector: #selector(scrollToNextPageAnimated), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userDidScroll = true
        if timer != nil {
            timer.invalidate()
            
            if let progressBarView = progressBarView {
                progressBarView.layer.removeAllAnimations()
                let frame = progressBarView.bounds
                progressBarView.frame = CGRect(x:frame.origin.x, y:frame.origin.y, width:scrollView.frame.width, height:frame.height) //width 0
                //                progressBarView.frame = frame
            }
        }
    }
    
    
    var progressBarView: UIView?
    func animateProgressBar() {
        guard let progressBarView = progressBarView else {
            return
        }
        
        if let frame = progressBarView.superview?.bounds {
            progressBarView.frame = frame
            
            UIView.animate(withDuration: sliderTimeInterval) {
                progressBarView.frame = CGRect(x:frame.origin.x, y:frame.origin.y, width:0, height:frame.height)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if toDisplayPage >= 0 {
            displayedPage = toDisplayPage
            configureTimer()
            toDisplayPage = -1
        }
    }
    
    override var collectionView: UICollectionView! {
        didSet {
            collectionView.isPagingEnabled = true
            scrollDirection = .horizontal
        }
    }
}





let cellController = CollectionCellController<UIColor, TextCell>(cellSize: CGSize(width: -1, height: -1))
cellController.configureCell = { cell, content, indexPath in
    cell.backgroundColor = content
    cell.label.text = "Test \(indexPath.item)"
}

let feedController = CircularCollectionController()
feedController.cellController = cellController

let pageControl = UIPageControl(frame: CGRect(origin: CGPoint(x:160, y:600 - 30), size: CGSize(width:50, height: 10)))
feedController.pageControl = pageControl
feedController.view.addSubview(pageControl)
feedController.content = [
        UIColor(red: 131/255, green: 198/255, blue: 204/255, alpha:1.0),
        UIColor(red: 120/255, green: 194/255, blue: 177/255, alpha: 1.0),
        UIColor(red: 223/255, green: 205/255, blue: 140/255, alpha:1.0)]

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.liveView = feedController.view
    














class TextCell : UICollectionViewCell {
    var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.backgroundColor = .white
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
