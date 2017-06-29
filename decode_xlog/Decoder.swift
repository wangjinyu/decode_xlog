//
//  Decoder.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//

import Cocoa
import Alamofire

protocol DecoderDelegate {
    func getCurrentLogUrlString() -> String?
    func updateDownloadProgress(progress:Float) -> Void
}

class Decoder: NSObject {
    
    public var delegate : DecoderDelegate?
    
    public var logUrlString : String?
    public var isDecoding : Bool = false;
    
    static let defaultDecoder = Decoder();
    
    fileprivate var downloadRequest : DownloadRequest?
    
    private override init() {
        super.init()
    }
    
    public func startDecode() {
        if ((self.delegate?.getCurrentLogUrlString()) != nil) {
            self.logUrlString = self.delegate?.getCurrentLogUrlString();
            if self.logUrlString?.isEmpty == false && ((self.logUrlString?.hasPrefix("http://"))! || (self.logUrlString?.hasPrefix("https://"))!) {
                self.isDecoding = true
                print("开始下载日志文件")
                self.downloadLogZipFile()
            } else {
                print("请先输入日志文件地址");
            }
        }
    }
    public func stopDecode() {
        self.isDecoding = false;
        print("停止解析");
    }
    
    public func downloadLogZipFile() {
        let urlString = URLRequest.init(url: URL.init(string: self.logUrlString!)!)
        let destination : DownloadRequest.DownloadFileDestination = { _, response in
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0];
            let fileURL = downloadsURL.appendingPathComponent(response.suggestedFilename!)
            return(fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        self.downloadRequest = Alamofire.download(urlString, to: destination)
        
        self.downloadRequest?.downloadProgress(closure: { progress in
            self.delegate?.updateDownloadProgress(progress: Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
        })
        
        self.downloadRequest?.responseData(completionHandler: { (response) in
            if response.result.isSuccess {
                let filename :String = (response.response?.suggestedFilename)!
                if filename.hasSuffix(".zip") {
                    print("下载成功. file_name = \(filename)")
                } else {
                    print("下载失败. error: 文件名不匹配. file_name = \(filename)")
                }
            
            } else if response.result.isFailure {
                print("下载失败 . error = \(String(describing: response.error))");
            }
        })
    }
}


