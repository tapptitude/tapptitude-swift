//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

enum Notifications {
    public class Notification<T, Identifier: Equatable> {
        internal var allObservers: [WeakContainer] = []
        
        public var observers: [RegisteredObserver] {
            let observers = allObservers.flatMap({ $0.value })
            
            if observers.count != allObservers.count {
                allObservers = allObservers.filter({ $0.value != nil }) // remove dead observers
            }
            
            return observers
        }
        
        
        public func register(identifier: Identifier?, callback: @escaping (T) -> Void) -> Any {
            let observation = RegisteredObserver(identifier: identifier, callback: callback)
            allObservers.append(WeakContainer(value: observation))
            return observation
        }
        
        public func post(_ payload: T, identifier: Identifier?) {
            observers.filter({ $0.identifier == nil || $0.identifier == identifier }).forEach { $0.callback(payload) }
        }
        
        
        internal var observersRegisteredByOwners: [RegisteredObserver] = []
        /// only while onwer is alive, callback will be triggered. No need to unregister
        public func register<Owner: AnyObject>(owner: Owner, identifier: Identifier?, callback: @escaping (Owner, T) -> Void) {
            let observation = RegisteredObserver(identifier: identifier, callback: { [weak owner, unowned self] payload in
                if let owner = owner {
                    callback(owner, payload)
                } else {
                    self.observersRegisteredByOwners = self.observersRegisteredByOwners.filter({ $0.owner != nil }) // remove observers with owner nil
                }
            })
            observation.owner = owner
            allObservers.append(WeakContainer(value: observation))
            observersRegisteredByOwners.append(observation)
        }
        
        public func remove(owner: AnyObject) {
            observersRegisteredByOwners = observersRegisteredByOwners.filter({ $0.owner !== owner }) // remove all registered with owner
        }
        
        public class RegisteredObserver: CustomDebugStringConvertible {
            
            public let identifier: Identifier?
            public var callback: (T) -> Void
            public weak var owner: AnyObject?
            
            public init(identifier: Identifier?, callback: @escaping (T) -> Void) {
                self.callback = callback
                self.identifier = identifier
            }
            
            var debugDescription: String {
                return String(describing: type(of: self)) + "_" + String(describing: T.self) + "_" + (identifier != nil ? String(describing:identifier!) : "")
            }
        }
        
        internal class WeakContainer {
            weak var value: RegisteredObserver?
            
            init(value: RegisteredObserver) {
                self.value = value
            }
        }
    }
}

extension Notifications.Notification where T == Void {
    func post(identifier: Identifier? = nil) {
        post((), identifier: identifier)
    }
    
    func register(identifier: Identifier? = nil, callback: @escaping () -> Void) -> Any {
        return register(identifier: identifier, callback: { (_) in
            callback()
        })
    }
}
