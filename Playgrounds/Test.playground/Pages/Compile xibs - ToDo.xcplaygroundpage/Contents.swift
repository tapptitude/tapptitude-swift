//: [Previous](@previous)

import Foundation


let task = NSTask()
task.launchPath = "ibtool"
task.arguments = ["--compile EditViewController.nib EditViewController.xib"]
task.launch()
task.waitUntilExit()

//ibtool --compile MainMenu.nib MainMenu.xib


//let pipe = NSPipe()
//task.standardOutput = pipe
//task.launch()
//let data = pipe.fileHandleForReading.readDataToEndOfFile()
//var dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
//NSLog(dataString) // TODO: write your own code

//: [Next](@next)
