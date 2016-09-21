//: Playground - noun: a place where people can play

import UIKit
import Tapptitude
import TTActionSheet
import XCPlayground


class MyViewController: UIViewController {
    var actionSheet: TTActionSheet!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SDFsd")

    }
    
    func show() {
        actionSheet = TTActionSheet(title: "Title", message: "Message", cancelMessage: "Cancel")
        actionSheet.addAction(TTActionSheetAction(title: "Action 1", handler: nil))
        actionSheet.addAction(TTActionSheetAction(title: "Action 2", handler: nil))
        actionSheet.addAction(TTActionSheetAction(title: "Action 3", handler: nil))
       self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}



let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 667))
let controller = MyViewController()
mainView.backgroundColor = UIColor.redColor()
controller.view = mainView

let _ = controller.view

let button = UIButton(frame: CGRect(x: 70, y: 600, width: 200, height: 60))
button.backgroundColor = UIColor.whiteColor()
button.setTitleColor(UIColor.blackColor(), forState: .Normal)
button.setTitle("Show action sheet", forState: .Normal)
button.addTarget(controller, action: #selector(MyViewController.show), forControlEvents: .TouchUpInside)

controller.view.addSubview(button)

XCPlaygroundPage.currentPage.liveView = controller.view

var str = "Hello, playground"
