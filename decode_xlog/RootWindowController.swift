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

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
    }
    
    @IBAction func startDecodeAction(_ sender: NSButton) {
        if Decoder.defaultDecoder.isDecoding == false {
            sender.image = NSImage.init(named: "stop_icon")
            sender.alternateImage = NSImage.init(named: "run_icon");
            Decoder.defaultDecoder.startDecode()
        } else {
            sender.image = NSImage.init(named: "run_icon")
            sender.alternateImage = NSImage.init(named: "stop_icon");
            Decoder.defaultDecoder.stopDecode()
        }
    }
}
