//
//  ViewController.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//


import Cocoa
import Alamofire

class ViewController: NSViewController,DecoderDelegate {

    @IBOutlet weak var textField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Decoder.defaultDecoder.delegate = self as DecoderDelegate;
        
        decode_swift.init().decode()
        
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
}

extension ViewController {
    func updateDecodeMessage(message: String) {
        print("\(message)")
    }
    
    func getCurrentLogUrlString() -> String? {
        return self.textField.stringValue
    }
}
