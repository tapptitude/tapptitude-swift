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
    var callback: (_ content: [String]?, _ error: NSError?)->Void
    
    init(callback: @escaping (_ content: [String]?, _ error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("test")
            if !self.wasCancelled {
                callback(["234"], nil)
            }
        }
    }
}


class APIPaginatedMock: TTCancellable {
    func cancel() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (_ content: [String]?, _ error: NSError?)->Void
    
    init(offset:Int, pageSize:Int, callback: @escaping (_ content: [String]?, _ error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if !self.wasCancelled {
                if offset > 3 {
                    print("completed")
                    callback(nil, nil)
                } else {
                    print("loaded")
                    callback(["Maria", "Ion"], nil)
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
    var callback: (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void
    
    init(offset:String?, limit:Int, callback: @escaping (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void) {
        self.callback = callback
        
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(nil, "1", nil)
                } else if offset == "1" {
                    callback([""], "2", nil)
                } else if offset == "2" {
                    callback([""], "3", nil)
                } else if offset == "3" {
                    callback(nil, "4", nil)
                } else if offset == "4" {
                    callback([""], "5", nil)
                } else if offset == "5" {
                    callback([""], nil, nil)
                }
            }
        }
    }
}
