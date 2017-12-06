//
//  TTActionSheetAction.swift
//  Tapptitude
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit

protocol TTActionSheetActionProtocol {
    var title: String { get set }
    var handler: (() -> Void)? { get set }
}

public class TTActionSheetAction: NSObject, TTActionSheetActionProtocol {
    var title: String
    var handler: (() -> Void)?
    
    public init(title: String) {
        self.title = title
    }
    
    public init(title: String, handler: (() -> Void)?) {
        self.title = title
        self.handler = handler
    }
}
