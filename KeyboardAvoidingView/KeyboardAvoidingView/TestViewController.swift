//
//  ViewController.swift
//  KeyboardAvoidingView
//
//  Created by Alexandru Tudose on 30/01/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.keyboard.addDismissTouchRecognizer()
        //        let controller = self.button.addKeyboardVisibilityController()
        //        controller.toBeVisibleView = self.view
        //        self.view.addKeyboardVisibilityController()
    }
}
