//
//  Result.swift
//  Tapptitude
//
//  Created by Alexandru Tudose on 04/03/2017.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
    
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
    public var value: Value? {
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

extension Result {
    /**
     Transform the result value, or propagate any errors gracefully.
     This can be used to transform the result without having to verify its content
     - parameters:
     - transform: the closure used to transform the original value
     - returns: a result with the transformed value, or the original error
     */
    public func map<NewValue>(_ transform: (Value) -> NewValue) -> Result<NewValue> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
//    public func map<NewValue: Collection>() -> Result<NewValue> {
//        switch self {
//        case .success(let value):
//            return .success(value.)
//        case .failure(let error):
//            return .failure(error)
//        }
//    }
}

extension Result where Value: Collection {
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

public typealias ResultTransform<From, Into> = ((Result<From>) -> (Result<Into>))
