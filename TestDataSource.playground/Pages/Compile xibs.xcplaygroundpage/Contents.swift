//: [Previous](@previous)

import Foundation


let task = NSTask()
task.launchPath = "ibtool"
task.arguments = ["--compile EditViewController.nib EditViewController.xib"]
task.launch()
task.waitUntilExit()


//: [Next](@next)
