import UIKit
import Tapptitude
import PlaygroundSupport

/*
 Check classes in Sources and storyboard in Resources for working example
 */

let storyboard = UIStoryboard(name: "Main", bundle: nil)

print(storyboard)

let controller = storyboard.instantiateInitialViewController() as! ChatFeedViewController

print(controller)
print(String(describing: controller))

controller.view.frame = CGRect(x: 20, y: 20, width: 250, height: 550)

PlaygroundPage.current.liveView = controller.view
PlaygroundPage.current.needsIndefiniteExecution = true

