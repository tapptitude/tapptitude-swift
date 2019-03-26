//
//  Result.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 04/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation

public typealias Result<Value> = Swift.Result<Value, Error>

extension Result {
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}


extension Result where Success: Collection {
    public func map<NewValue>(as type: NewValue.Type) -> Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func map<NewValue>() -> Result<[NewValue]> {
        switch self {
        case .success(let value):
            return .success(value.map({$0 as! NewValue }))
        case .failure(let error):
            return .failure(error)
        }
    }
}
