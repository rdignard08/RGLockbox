//
//  ViewController.swift
//  RGLockboxExample
//
//  Created by Ryan Dignard on 8/7/16.
//  Copyright © 2016 Ryan Dignard. All rights reserved.
//

import UIKit
import RGLockboxIOS

let theKey = "theKey"

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var recallButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField?.text = RGLockbox.manager().stringForKey(theKey)
    }

    @IBAction func pressedSave() {
        RGLockbox.manager().setString(self.textField?.text, key: theKey)
    }
    
    @IBAction func pressedRecall() {
        self.textField?.text = RGLockbox.manager().stringForKey(theKey)
    }
}

