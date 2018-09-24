//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct APIError: Error {
    enum Type_: String {
        case missingSession = "MissingSession"
        case unkown
    }
    
    var code: String // switch to `Int` type if backend return
    var message: String
    var type: Type_
}


extension APIError: Decodable {
    private enum CodingKeys: String, CodingKey {
        case code, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //        container = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error) // fetch error container
        code = try container.decode(String.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        type = Type_(rawValue: code) ?? .unkown
    }
}

extension APIError: LocalizedError {
    var localizedDescription: String {
        return message
    }
}


// -- helpers method for equality

func ==(lhs: Error, rhs: APIError.Type_) -> Bool {
    switch lhs {
    case let error as APIError:
        return error.type == rhs
    default:
        return false
    }
}

func ==(lhs: Error?, rhs: APIError.Type_) -> Bool {
    if let error = lhs {
        return error == rhs
    } else {
        return false
    }
}

func ==(lhs: APIError, rhs: Error) -> Bool {
    return rhs == lhs.type
}

func ==(lhs: Error, rhs: APIError) -> Bool {
    return lhs == rhs.type
}
