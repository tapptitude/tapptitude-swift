//
//  ImagesFullScreenCell.swift
//  Bildnytt
//
//  Created by Ion Toderasco on 01/08/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit

class ImagesFullScreenCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeft: NSLayoutConstraint!
    @IBOutlet weak var imageViewRight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.layoutIfNeeded()
        self.imageView.transform = CGAffineTransformIdentity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMinimumZoomScale()
        updateConstraintsForSize(self.bounds.size)
    }
    
    func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - self.imageView.frame.size.height) / 2)
        let xOffset = max(0, (size.width - self.imageView.frame.size.width) / 2)
        
        self.imageViewTop.constant = yOffset
        self.imageViewBottom.constant = yOffset
        self.imageViewLeft.constant = xOffset
        self.imageViewRight.constant = xOffset
        self.layoutIfNeeded()
    }
    
    func updateMinimumZoomScale() {
        self.layoutIfNeeded()
        guard self.imageView.image != nil else { return }
        
        let widthScale: CGFloat = self.bounds.size.width / self.imageView.image!.size.width
        let heightScale: CGFloat = self.bounds.size.height / self.imageView.image!.size.height
        let minScale: CGFloat = min(widthScale, heightScale)
        var setMinScale = false
        
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            setMinScale = true
        }
        
        self.scrollView.minimumZoomScale = minScale
        if self.scrollView.zoomScale < minScale || setMinScale {
            self.scrollView.zoomScale = minScale
        }
    }
    
    func toggleZoomAtPoint(point: CGPoint) {
        let imagePoint = imageView.convertPoint(point, fromView: self)
        let minimumZoomScale = scrollView.minimumZoomScale
        
        if scrollView.zoomScale > minimumZoomScale {
            //Zoom out
            scrollView.setZoomScale(minimumZoomScale, animated: true)
        } else {
            //Zoom in
            let maximumZoomScale = scrollView.maximumZoomScale
            let newZoomScale = min(minimumZoomScale * 2, maximumZoomScale)
            let width = self.bounds.size.width / newZoomScale
            let height = self.bounds.size.height / newZoomScale
            let zoomRect = CGRectMake(imagePoint.x - width / 2, imagePoint.x - height / 2, width, height)
            scrollView.zoomToRect(zoomRect, animated: true)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.updateConstraintsForSize(self.bounds.size)
    }
}
