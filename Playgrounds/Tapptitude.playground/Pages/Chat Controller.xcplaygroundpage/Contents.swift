import UIKit
import Tapptitude
import PlaygroundSupport




print(String(describing: ChatFeedViewController()))

let storyboard = UIStoryboard(name: "Main", bundle: nil)
let controller = storyboard.instantiateInitialViewController()!

print(String(describing:controller))

//controller.view.frame.size = CGSize(width: 320, height: 480)
//let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
//window.rootViewController = controller
//window.makeKeyAndVisible()

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true
