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

class APIPaginateOffsetdSwiftMock: TTCancellable {
    func cancel() {
    }
    
    
    static func getResults(offset:String?, callback: @escaping (_ content: [String]?, _ nextOffset:String?, _ error: NSError?)->Void) -> TTCancellable? {
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if offset == nil {
                callback([Example.text0], "1", nil)
            } else if offset == "1" {
                callback([Example.text1], "2", nil)
            } else if offset == "2" {
                callback([Example.text2], "3", nil)
            } else if offset == "3" {
                callback([Example.text3], "4", nil)
            } else if offset == "4" {
                callback([Example.text4], nil, nil)
            }
        }
        
        return nil
    }
}

enum Example {
    static let text1 = "Swift is a general-purpose, multi-paradigm, compiled programming language developed by Apple Inc. for iOS, macOS, watchOS, tvOS, and Linux. Swift is designed to work with Apple's Cocoa and Cocoa Touch frameworks and the large body of extant Objective-C (ObjC) code written for Apple products. Swift is intended to be more resilient to erroneous code (\"safer\") than Objective-C, and more concise. It is built with the LLVM compiler framework included in Xcode 6 and later and, on platforms other than Linux,[11] uses the Objective-C runtime library, which allows C, Objective-C, C++ and Swift code to run within one program.[12]"
    
    static let text2 =     "Swift supports the core concepts that made Objective-C flexible, notably dynamic dispatch, widespread late binding, extensible programming and similar features. These features also have well known performance and safety trade-offs, which Swift was designed to address. For safety, Swift introduced a system that helps address common programming errors like null pointers, and introduced syntactic sugar to avoid the pyramid of doom that can result. For performance issues, Apple has invested considerable effort in aggressive optimization that can flatten out method calls and accessors to eliminate this overhead. More fundamentally, Swift has added the concept of protocol extensibility, an extensibility system that can be applied to types, structs and classes. Apple promotes this as a real change in programming paradigms they term \"protocol-oriented programming\".[13]"
    
    static let text3 = "Swift was introduced at Apple's 2014 Worldwide Developers Conference (WWDC).[14] It underwent an upgrade to version 1.2 during 2014 and a more major upgrade to Swift 2 at WWDC 2015. Initially a proprietary language, version 2.2 was made open-source software and made available under Apache License 2.0 on December 3, 2015, for Apple's platforms and Linux.[15][16] IBM announced its Swift Sandbox website, which allows developers to write Swift code in one pane and display output in another.[17][18][19]"
    
    static let text4 = "A second free implementation of Swift that targets Cocoa, Microsoft's Common Language Infrastructure (.NET), and the Java and Android platform exists as part of the Elements Compiler from RemObjects Software.[20] Since the language is open-source, there are prospects of it being ported to the web.[21] Some web frameworks have already been developed, such as IBM's Kitura, Perfect[22][23] and Vapor. An official \"Server APIs\" work group has also been started by Apple,[24] with members of the Swift developer community playing a central role.[25]"
    
    static let text0 = "Swift is an alternative to the Objective-C language that employs modern programming-language theory concepts and strives to present a simpler syntax. During its introduction, it was described simply as \"Objective-C without the C\".[40][41]"
    
    static func allTest() -> [String] {
        return [text1, text0, text2, text3, text4]
    }
}
