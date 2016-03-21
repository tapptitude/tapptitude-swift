//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

final class User {
    var userID : NSString?
    
    var firstName : String?
    var lastName : String?
    
    func fullName() -> String? {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}
