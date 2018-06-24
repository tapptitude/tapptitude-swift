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
    
    private let contentSize = "contentSize"
    private let contentOffset = "contentOffset"
    private let frame = "frame"
    private let contentInset = "contentInset"
    
    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        collectionView = nil
    }
    
    override var collectionView: UICollectionView! {
        willSet {
            if let collectionView  = collectionView {
                collectionView.removeObserver(self, forKeyPath: contentSize)
                collectionView.removeObserver(self, forKeyPath: contentInset)
                collectionView.removeObserver(self, forKeyPath: frame)
                scrollView.removeObserver(self, forKeyPath: contentOffset)
            }
        }
        didSet {
            if let collectionView = collectionView {
                collectionView.addObserver(self, forKeyPath: contentSize, options: .new, context: nil)
                collectionView.addObserver(self, forKeyPath: contentInset, options: .new, context: nil)
                collectionView.addObserver(self, forKeyPath: frame, options: .new, context: nil)
                scrollView.addObserver(self, forKeyPath: contentOffset, options: .new, context: nil)
                
                collectionView.removeGestureRecognizer(collectionView.panGestureRecognizer)
                collectionView.addGestureRecognizer(scrollView.panGestureRecognizer)
            }
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
    
    @IBOutlet weak var pageControl: UIPageControl?
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == contentOffset {
            updateCollectionViewOffset()
        } else if keyPath == contentSize || keyPath == frame || keyPath == contentInset {
            self.updateScollViewFrame()
            self.updateScrollViewContentSize()
            //            updateCollectionViewOffset()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
}


//: [Next](@next)
