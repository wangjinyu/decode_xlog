//
//  ViewController.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//


import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.focusRingType = .none
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }

}

