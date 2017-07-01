//
//  RootWindowController.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//

import Cocoa

class RootWindowController: NSWindowController {
    @IBOutlet weak var toolBar: NSToolbar!
    @IBOutlet weak var decodeButton: NSButton!

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "decode_complete"), object: nil, queue: OperationQueue.main) { (notification) in
            self.decodeButton.image = NSImage.init(named: "run_icon")
            self.decodeButton.alternateImage = NSImage.init(named: "stop_icon");
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "decode_error"), object: nil, queue: OperationQueue.main) { (notification) in
            self.decodeButton.image = NSImage.init(named: "run_icon")
            self.decodeButton.alternateImage = NSImage.init(named: "stop_icon");
        }
    }
    
    @IBAction func startDecodeAction(_ sender: NSButton) {
        if Decoder.defaultDecoder.isDecoding == false {
            sender.image = NSImage.init(named: "stop_icon")
            sender.alternateImage = NSImage.init(named: "run_icon");
            Decoder.defaultDecoder.startDecode()
        }
    }
}
