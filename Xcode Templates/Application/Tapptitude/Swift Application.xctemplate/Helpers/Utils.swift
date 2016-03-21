//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)

    )
}

func NSStringFormat(format: String!, args: CVarArgType) -> String {
    return NSString(format: format, args) as String
}

enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == endIdx ? terminator : separator)
             idx += 1
        }
            while idx < endIdx
        
    #endif
}

//func dispatch_after_on_main_queue (delayInSeconds: Double , closure: ()->()) {
//    let popTime = dispatch_time(DISPATCH_TIME_NOW,  Int64(delayInSeconds * Double(NSEC_PER_SEC)));
//    dispatch_after(popTime, dispatch_get_main_queue(), closure);
//}
//
//func dispatch_async_on_main_queue (closure: ()->()) {
//    dispatch_async(dispatch_get_main_queue(), closure);
//}
//
//func dispatch_sync_on_main_queue (closure: ()->()) {
//    if (NSThread.isMainThread()) {
//        closure();
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), closure);
//    }
//}