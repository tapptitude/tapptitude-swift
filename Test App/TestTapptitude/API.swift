//
//  API.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 25/03/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import Tapptitude

class APIMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [String]?, error: NSError?)->Void
    
    init(callback: (content: [String]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                callback(content: ["234"], error: nil)
            }
        }
    }
}


class APIPaginatedMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [String]?, error: NSError?)->Void
    
    init(offset:Int, limit:Int, callback: (content: [String]?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                if offset > 3 {
                    callback(content: nil, error: nil)
                } else {
                    callback(content: ["234"], error: nil)
                }
            }
        }
    }
}


class APIPaginateOffsetdMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (content: [String]?, nextOffset:String?, error: NSError?)->Void
    
    init(offset:String?, limit:Int, callback: (content: [String]?, nextOffset:String?, error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(content: nil, nextOffset: "1", error: nil)
                } else if offset == "1" {
                    callback(content: [""], nextOffset: "2", error: nil)
                } else if offset == "2" {
                    callback(content: [""], nextOffset: "3", error: nil)
                } else if offset == "3" {
                    callback(content: nil, nextOffset: "4", error: nil)
                } else if offset == "4" {
                    callback(content: [""], nextOffset: "5", error: nil)
                } else if offset == "5" {
                    callback(content: [""], nextOffset: nil, error: nil)
                }
            }
        }
    }
}