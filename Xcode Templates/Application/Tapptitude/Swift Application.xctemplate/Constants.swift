//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

struct Constants {
    #if APPSTORE
    static let API_URL = "your api url"
    static let API_KEY = "your api key"
    #elseif DEV
    static let API_URL = "your api url"
    static let API_KEY = "your api key"
    #endif
}



//MARK: - Notifications
extension Notifications {
    static let sessionClosed = Notification<Error?, String>() // payload, identity of payload
//    static let userDidCheckin = Notification<User, String>() // payload, identity of payload
//    static let userChangedTeam = Notification<Void, String>() // payload, identity of payload
}
