//
//  JSONDecoder+KeyPath.swift
//  Decodable
//
//  Created by Alexandru Tudose on 08/12/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation

extension JSONDecoder {
    open func decode<T>(_ type: T.Type, from data: Data, keyPath: String, separator: Character = ".") throws -> T where T : Decodable {
        self.userInfo[JSONDecoder.keyPaths] = keyPath.split(separator: separator).map({ String($0) })
        return try decode(ProxyModel<T>.self, from: data).object
    }
    
    fileprivate static let keyPaths: CodingUserInfoKey = CodingUserInfoKey(rawValue: "keyPath")!
}


extension JSONDecoder {
    struct ProxyModel<T: Decodable>: Decodable {
        var object: T
        
        struct Key: CodingKey {
            let stringValue: String
            let intValue: Int? = nil
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            init?(intValue: Int) {
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws {
            let stringKeyPaths = decoder.userInfo[JSONDecoder.keyPaths] as! [String]
            var keyPaths = stringKeyPaths.map({ Key(stringValue: $0)! })
            var container = try! decoder.container(keyedBy: Key.self)
            var key = keyPaths.removeFirst()
            for newKey in keyPaths {
                container = try container.nestedContainer(keyedBy: Key.self, forKey: key)
                key = newKey
            }
            
            object = try container.decode(T.self, forKey: key)
        }
    }
}
