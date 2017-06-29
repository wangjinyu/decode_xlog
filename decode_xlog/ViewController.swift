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
        
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }

    func getCurrentLogUrlString() -> String? {
        return self.textField.stringValue
    }
    
    func updateDownloadProgress(progress: Float) {
        print("progress : \(progress)")
    }
}

