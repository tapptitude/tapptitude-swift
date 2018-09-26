//: [Previous](@previous)

import UIKit
import Tapptitude

@objc public protocol PageControl: class {
    var numberOfPages: Int { get set }
    var currentPage: Int { get set }
}
extension UIPageControl: PageControl {
}

class PaginatedCollectionController: CollectionFeedController {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        return scrollView
    }()
    
    private var contentSizeObserver: Any?
    private var contentOffsetObserver: Any?
    private var frameObserver: Any?
    private var contentInsetObserver: Any?
    
    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        collectionView = nil
    }
    
    override var collectionView: UICollectionView! {
        didSet {
            if let collectionView = collectionView {
                collectionView.removeGestureRecognizer(collectionView.panGestureRecognizer)
                collectionView.addGestureRecognizer(scrollView.panGestureRecognizer)
            }
            
            setupObservers()
        }
    }
    
    var content: [Any] {
        return dataSource?.content_ ?? []
    }
    override var _dataSource: TTAnyDataSource? {
        didSet {
            pageControl?.numberOfPages = content.count
            (pageControl as? UIView)?.isHidden = content.count < 2
        }
    }
    private var toDisplayPage: Int = -1 //ingore
    
    @IBOutlet weak var pageControl: PageControl?
    
    var displayedPage: Int {
        get {
            let pageWidth = scrollView.bounds.size.width
            if pageWidth < 0.01 {
                return 0
            }
            let page = Int(floor((scrollView.contentOffset.x / pageWidth)))
            return page
        }
        set {
            pageControl?.currentPage = newValue
            let indexPath = IndexPath(item: newValue, section: 0)
            let pageWidth = scrollView.bounds.size.width
            
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.x = CGFloat(newValue) * pageWidth
            }
            
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = displayedPage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if toDisplayPage >= 0 {
            displayedPage = toDisplayPage
            toDisplayPage = -1
        }
    }
    
    func updateScrollViewContentSize() {
        if collectionView!.contentSize != scrollView.contentSize {
            print("from contentSize: ", scrollView.contentSize, " --> ", collectionView!.contentSize, "\n")
            scrollView.contentSize = collectionView!.contentSize
        }
    }
    
    func updateCollectionViewOffset() {
        let offset = scrollView.contentOffset
        let inset = collectionView!.contentInset
        collectionView!.contentOffset = CGPoint(x: offset.x - inset.left, y: offset.y - inset.top)
    }
    
    func updateScollViewFrame () {
        let frame = collectionView!.frame.inset(by: collectionView!.contentInset)
        if frame != scrollView.frame {
            scrollView.frame = frame
            print("from frame: ", collectionView!.frame.size, " --> ", scrollView.frame.size, "\n")
        }
    }
    
    func setupObservers() {
        contentSizeObserver = collectionView.observe(\.contentSize) { [weak self] (_, _) in
            self?.updateScollViewFrame()
            self?.updateScrollViewContentSize()
        }
        contentInsetObserver = collectionView.observe(\.contentInset) { [weak self] (_, _) in
            self?.updateScollViewFrame()
            self?.updateScrollViewContentSize()
        }
        frameObserver = collectionView.observe(\.frame) { [weak self] (_, _) in
            self?.updateScollViewFrame()
            self?.updateScrollViewContentSize()
        }
        contentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] (_, _) in
            self?.updateCollectionViewOffset()
        }
    }
}

let feedController = PaginatedCollectionController()
feedController.scrollDirection = .horizontal
feedController.cellController = FullIntCellController()
feedController.dataSource = DataSource([1, 2, 3])

import PlaygroundSupport
feedController.view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
PlaygroundPage.current.liveView = feedController.view

//: [Next](@next)
