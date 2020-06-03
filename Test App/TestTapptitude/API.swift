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
    func cancelRequest() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: (_ content: [String]?, _ error: NSError?)->Void
    
    init(callback: @escaping (_ content: [String]?, _ error: NSError?)->Void) {
        self.callback = callback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("test")
            if !self.wasCancelled {
                callback(["234"], nil)
            }
        }
    }
}


class APIPaginatedMock: TTCancellable {
    func cancelRequest() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: TTCallback<[String]>
    
    init(offset:Int, pageSize:Int, callback: @escaping TTCallback<[String]>) {
        self.callback = callback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if !self.wasCancelled {
                if offset > 3 {
                    print("completed")
                    callback(.success([]))
                } else {
                    print("loaded")
                    callback(.success(["Maria", "Ion"]))
                }
            }
        }
    }
}


class APIPaginateOffsetdMock: TTCancellable {
    func cancelRequest() {
        wasCancelled = true
    }
    
    var wasCancelled = false
    var callback: TTCallback<([String], String?)>
    
    init(offset:String?, limit:Int, callback: @escaping TTCallback<([String], String?)>) {
        self.callback = callback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("test")
            if !self.wasCancelled {
                if offset == nil {
                    callback(.success(([], "1")))
                } else if offset == "1" {
                    callback(.success(([""], "2")))
                } else if offset == "2" {
                    callback(.success(([""], "3")))
                } else if offset == "3" {
                    callback(.success(([], "4")))
                } else if offset == "4" {
                    callback(.success(([""], "5")))
                } else if offset == "5" {
                    callback(.success(([""], nil)))
                }
            }
        }
    }
}

class APIPaginateOffsetdSwiftMock: TTCancellable {
    func cancelRequest() {
    }
    
    
    static func getResults(offset:String?, callback: @escaping TTCallback<([String], String?)> ) -> TTCancellable? {
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if offset == nil {
                callback(.success(([Example.text0], "1")))
            } else if offset == "1" {
                callback(.success(([Example.text1], "2")))
            } else if offset == "2" {
                callback(.success(([Example.text2], "3")))
            } else if offset == "3" {
                callback(.success(([Example.text3], "4")))
            } else if offset == "4" {
                callback(.success(([], nil)))
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
