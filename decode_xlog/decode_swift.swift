//
//  decode_swift.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/30.
//  Copyright © 2017年 jinyu. All rights reserved.
//

import Cocoa

let magic_no_compress_start  = Int8(0x03)
let magic_compress_start    = Int8(0x03)
let magic_compress_start_1  = Int8(0x03)
let magic_end = 0x00
let lastseq = 0

class decode_swift: NSObject {
    override init() {
        super.init()
    }
    
    public func decode() {
        do {
            let file_data = try Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "speedx_100062_20170627", ofType: "xlog")!))
            
            let string :String = String.init(data: file_data.subdata(in: 13..<file_data.count), encoding: String.Encoding.utf8)!
            
            let utf8_string = NSString.init(cString: string, encoding: String.Encoding.ascii.rawValue)
            
            print(string)
            
            do {
                let docuemntURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0];
                let path = docuemntURL.appendingPathComponent("speedx_100062_20170627.log");
                try utf8_string?.write(to: path, atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch  {
                print("文件写入错误")
            }
            
//            print("file_data = \n\(string)")
        } catch  {
            print("文件读取错误");
        }
        
    }
    
}
