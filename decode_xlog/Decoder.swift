//
//  Decoder.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//

import Cocoa

class Decoder: NSObject {
    public var logUrlString : String?
    public var isDecoding : Bool?
    override init() {
        super.init()
    }
    
    public func startDecode() {
        print("开始下载日志文件");
    }
}
