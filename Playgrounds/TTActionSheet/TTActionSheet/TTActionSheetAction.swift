//
//  TTActionSheetAction.swift
//  test
//
//  Created by Efraim Budusan on 9/6/16.
//  Copyright © 2016 Efraim Budusan. All rights reserved.
//

import UIKit

public class TTActionSheetAction: NSObject {
    var title:String
    var handler: (() -> Void)?
    public init(title:String, handler:(() -> Void)?) {
        self.title = title
        self.handler = handler
    }
}
