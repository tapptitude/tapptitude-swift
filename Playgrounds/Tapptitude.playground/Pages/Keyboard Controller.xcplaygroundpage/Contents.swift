//: [Previous](@previous)

import UIKit
import Tapptitude

class KeyboardViewController: UIViewController {
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardVisibilityController()
    }
    
    func addKeyboardVisibilityController() {
        let keyboardController = textFieldContainer.addKeyboardVisibilityController()
        keyboardController.toBeVisibleView = textFieldContainer
        //    keyboardController.dismissKeyboardTouchRecognizer.ignoreViews = @[self.inputContainerView];
        keyboardController.dismissKeyboardTouchRecognizer = nil
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        self.view.endEditing(true)
        var newY = self.textFieldContainer.frame.origin.y
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: newY = self.view.frame.size.height - self.textFieldContainer.frame.size.height
        case 1: newY = self.view.frame.size.height - 200
        case 2: newY = 40
        default: break
        }
        
        moveTextFieldContainerAtYCoordinate(newY)
    }
    
    
    func moveTextFieldContainerAtYCoordinate(y: CGFloat) {
        self.textFieldContainer.transform = CGAffineTransformIdentity
        var frame = self.textFieldContainer.frame
        frame.origin.y = y
        self.textFieldContainer.frame = frame
    }
}


import XCPlayground
let controller = KeyboardViewController(nibName: "KeyboardViewController", bundle: nil)
XCPlaygroundPage.currentPage.liveView = controller.view
//: [Next](@next)
