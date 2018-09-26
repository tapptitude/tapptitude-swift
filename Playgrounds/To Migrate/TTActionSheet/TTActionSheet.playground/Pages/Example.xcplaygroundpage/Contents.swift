//: Playground - noun: a place where people can play

import UIKit
import Tapptitude
import TTActionSheet
import XCPlayground


class MyViewController: UIViewController {
    var actionSheet: TTActionSheet!
    
    func show() {
        actionSheet = TTActionSheet(title: "Title", message: "Message", cancelMessage: "Cancel")
        actionSheet.addAction(TTActionSheetAction(title: "Action 1", handler: { print("action 1") }))
        actionSheet.addAction(TTActionSheetAction(title: "Action 2", handler: { print("action 2") }))
        actionSheet.addAction(TTActionSheetAction(title: "Action 3", handler: { print("action 3") }))
       self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}



let controller = MyViewController()
controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 667)
controller.view.backgroundColor = UIColor.brownColor()

let button = UIButton(frame: CGRect(x: 70, y: 600, width: 200, height: 60))
button.layer.cornerRadius = 6
button.backgroundColor = UIColor.whiteColor()
button.setTitleColor(UIColor.blackColor(), forState: .Normal)
button.setTitle("Show action sheet", forState: .Normal)
button.addTarget(controller, action: #selector(MyViewController.show), forControlEvents: .TouchUpInside)

controller.view.addSubview(button)

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 350, height: 667))
window.rootViewController = controller
window.makeKeyAndVisible()
XCPlaygroundPage.currentPage.liveView = window