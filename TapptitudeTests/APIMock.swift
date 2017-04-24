//
//  APIMock.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 28/01/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation
import Tapptitude
import Dispatch

class APIMock: TTCancellable {
    
    var wasCancelled = false
    var callback: ((_ result: Result<[String]>)->Void)!
    var content: [String]?
    var error: Error?
    
    var delay = 0.0001
    
    init () {
        
    }
    
    func cancel() {
        wasCancelled = true
    }
    
    func run() {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.runCallback()
            }
        } else {
            runCallback()
        }
    }
    
    func runCallback() {
        if !self.wasCancelled {
            if let content = self.content {
                self.callback(Result.success(content))
            } else if let error = self.error {
                self.callback(Result.failure(error))
            } else {
                abort()
            }
        }
    }
}


//class APIPaginatedMock: TTCancellable {
//    func cancel() {
//        wasCancelled = true
//    }
//    
//    var wasCancelled = false
//    var callback: (_ content: [String]?, _ error: NSError?)->Void
//    
//    init(offset:Int, pageSize:Int, callback: @escaping (_ content: [String]?, _ error: NSError?)->Void) {
//        self.callback = callback
//        
//        let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            if !self.wasCancelled {
//                if offset > 3 {
//                    print("completed")
//                    callback(nil, nil)
//                } else {
//                    print("loaded")
//                    callback(["Maria", "Ion"], nil)
//                }
//            }
//        }
//    }
//}


//class APIPaginateOffsetdMock: TTCancellable {
//    func cancel() {
//        wasCancelled = true
//    }
//    
//    var wasCancelled = false
//    var callback: (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void
//    
//    init(offset:String?, limit:Int, callback: @escaping (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void) {
//        self.callback = callback
//        
//        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            print("test")
//            if !self.wasCancelled {
//                if offset == nil {
//                    callback(nil, "1", nil)
//                } else if offset == "1" {
//                    callback([""], "2", nil)
//                } else if offset == "2" {
//                    callback([""], "3", nil)
//                } else if offset == "3" {
//                    callback(nil, "4", nil)
//                } else if offset == "4" {
//                    callback([""], "5", nil)
//                } else if offset == "5" {
//                    callback([""], nil, nil)
//                }
//            }
//        }
//    }
//}
//
//class APIPaginateOffsetdSwiftMock: TTCancellable {
//    func cancel() {
//    }
//    
//    
//    static func getResults(offset:String?, callback: @escaping (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void) -> TTCancellable? {
//        let content = [("0", "1"), ("1", "2"), ("2", "3"), ("4", nil)]
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            if offset == nil {
//                callback(["0"], "1", nil)
//            } else if offset == "1" {
//                callback(["1"], "2", nil)
//            } else if offset == "2" {
//                callback(["2"], "3", nil)
//            } else if offset == "3" {
//                callback(["3"], "4", nil)
//            } else if offset == "4" {
//                callback(["4"], nil, nil)
//            }
//        }
//        
//        return nil
//    }
//}
