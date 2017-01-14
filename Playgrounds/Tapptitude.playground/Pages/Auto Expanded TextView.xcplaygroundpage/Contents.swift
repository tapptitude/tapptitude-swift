//: [Previous](@previous)

import UIKit

// TODO: Add this

//: [Next](@next)

import Tapptitude

class TestViewController: CollectionFeedController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    
    override func registerForceTouchPreview() {
        super.registerForceTouchPreview()
        print("parent registerForceTouchPreview", )
    }
}

let testController = TestViewController()
testController.registerForceTouchPreview()