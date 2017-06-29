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
    public var isDecoding : Bool = false;
    
    static let defaultDecoder = Decoder();
    
    private override init() {
        super.init()
    }
    
    public func startDecode() {
        self.isDecoding = true;
        print("开始下载日志文件");
    }
    public func stopDecode() {
        self.isDecoding = false;
        print("停止解析");
    }
    
    
}
