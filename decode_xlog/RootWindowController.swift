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

    }
    
    @IBAction func startDecodeAction(_ sender: NSToolbarItem) {
        let decoder :Decoder = Decoder();
        decoder.startDecode();
    }
}
