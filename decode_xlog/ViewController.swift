//
//  ViewController.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//


import Cocoa
import Alamofire
import SwiftShell

class ViewController: NSViewController, DecoderDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    fileprivate var messageList :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Decoder.defaultDecoder.delegate = self as DecoderDelegate;
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "decode_complete"), object: nil, queue: OperationQueue.main) { (notification) in
            self.textField.stringValue = ""
            self.messageList.append("         ")
            self.tableView.reloadData()
        }
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
}

extension ViewController {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.messageList.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25.0;
    }

    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        return self.view.frame.size.width
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView : NSTableCellView = tableView.make(withIdentifier: "cell", owner: self) as! NSTableCellView
        if self.messageList[row].hasPrefix("日志文件解码完成") {
            cellView.textField?.textColor = NSColor.green
        } else if self.messageList[row].hasPrefix("[Error]") {
        cellView.textField?.textColor = NSColor.red
        } else {
            cellView.textField?.textColor = NSColor.black
        }
        cellView.textField?.stringValue = self.messageList[row]
        
        return cellView;
    }
}

extension ViewController {
    func updateDecodeMessage(message: String) {
        self.messageList.append(message)
        self.tableView.reloadData()
        self.tableView.scrollRowToVisible(self.messageList.count - 1)
    }
    
    func getCurrentLogUrlString() -> String? {
        return self.textField.stringValue
    }
}
