//
//  Decoder.swift
//  decode_xlog
//
//  Created by jinyu on 2017/6/28.
//  Copyright © 2017年 jinyu. All rights reserved.
//

import Cocoa
import Alamofire
import Zip
import SwiftShell

let magic_no_compress_start  = UInt8(0x03)

protocol DecoderDelegate {
    func getCurrentLogUrlString() -> String?
    func updateDecodeMessage(message : String) -> Void
}

class Decoder: NSObject {
    
    public var delegate : DecoderDelegate?
    
    public var logUrlString : String? {
        didSet {
            self.delegate?.updateDecodeMessage(message: "日志文件 url : \(String(describing: self.logUrlString!))")
        }
    }
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
                self.delegate?.updateDecodeMessage(message: "开始下载日志文件...")
                self.downloadLogZipFile()
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
                self.isDecoding = false
                self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件 url 不合法")
            }
        }
    }
    
    fileprivate func downloadLogZipFile() {
        let urlString = URLRequest.init(url: URL.init(string: self.logUrlString!)!)
        let destination : DownloadRequest.DownloadFileDestination = { _, response in
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0];
            let fileURL = downloadsURL.appendingPathComponent("feedback_logs").appendingPathComponent(response.suggestedFilename!)
            return(fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        self.downloadRequest = Alamofire.download(urlString, to: destination)
        
        self.downloadRequest?.downloadProgress(closure: { progress in
        })
        
        self.downloadRequest?.responseData(completionHandler: { (response) in
            if response.result.isSuccess {
                let filename :String = (response.response?.suggestedFilename)!
                if filename.hasSuffix(".zip") {
                    self.delegate?.updateDecodeMessage(message: "日志文件下载完成. file_name : \(filename)")
                    self.getXlogFilesWithZipFile(zipFilePath: (response.destinationURL)!);
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
                    self.isDecoding = false
                    self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件下载失败. 不是合法的日志文件 : \(filename)")
                }
            
            } else if response.result.isFailure {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
                self.isDecoding = false
                self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件下载失败. erro : \(String(describing: response.error))")
            }
        })
    }
}

extension Decoder {
    fileprivate func getXlogFilesWithZipFile (zipFilePath:URL) {
        do {
            let zip_file_name = zipFilePath.lastPathComponent
            let unzip_file_directory = zip_file_name.components(separatedBy: ".")[0]
            
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0];
            let fileURL = downloadsURL.appendingPathComponent("feedback_logs").appendingPathComponent(unzip_file_directory)
            self.delegate?.updateDecodeMessage(message: "开始解压日志文件... file_name : \(zip_file_name)")
            
            var file_names : [String] = [];
            
            try Zip.unzipFile(zipFilePath, destination: fileURL, overwrite: true, password: "", progress: { (progress) in
                if progress == 1.0 {
                    self.delegate?.updateDecodeMessage(message: "xlog 日志文件解压完成.")
                    //删除 zip 文件
                    try? FileManager.default.removeItem(at: zipFilePath)
                    
                    file_names = try! FileManager.default.contentsOfDirectory(atPath: fileURL.absoluteString.components(separatedBy: "://").last!)
                    
                    
                    for file in file_names {
                        if file.hasSuffix(".xlog") == true {
                            self.delegate?.updateDecodeMessage(message: "开始解码日志文件... file_name : \(file)")
                            let file_url = fileURL.appendingPathComponent(file)
                            _ = self.decode_xlog_file(file_url: file_url, distination: fileURL)
                        }
                    }

                    file_names = try! FileManager.default.contentsOfDirectory(atPath: fileURL.absoluteString.components(separatedBy: "://").last!)
                    
                    if file_names.count > 1 {
                        run("open", fileURL)
                    } else {
                        let url = fileURL.appendingPathComponent(file_names.first!)
                        run("open", (url.absoluteString.components(separatedBy: "://").last!))
                    }
                    self.isDecoding = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "decode_complete"), object: nil)
                }
            })
            
        } catch ZipError.unzipFail {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
            self.isDecoding = false
            self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件解压失败 : \(ZipError.unzipFail)")
        } catch ZipError.fileNotFound {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
            self.isDecoding = false
            self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件解压失败, 文件不存在 : \(ZipError.fileNotFound)")
        } catch {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
            self.isDecoding = false
            self.delegate?.updateDecodeMessage(message: "[Error]. 日志文件解压失败, 未知错误")
        }
    }
    
    fileprivate func decode_xlog_file(file_url : URL, distination: URL) -> Bool {
        do {
            var file_data = try Data.init(contentsOf: file_url)
            var log_string = ""
            
            while file_data.count > 0 {
                let header_info:Data = file_data.subdata(in: 0..<13)
                let log_start = header_info[0];
                var log_length = 0;
                for i in 5...8 {
                    log_length += Int(header_info[i]) * Int(pow(16.0, (Float(i) - 5.0) * 2.0))
                }
                if log_start == magic_no_compress_start {
                    let log_data = file_data.subdata(in: 13..<(13 + log_length))
                    let string = String.init(data: log_data, encoding: String.Encoding.utf8)!
                    log_string = log_string.appending(string);
                    file_data = file_data.subdata(in: (13 + log_length + 1)..<file_data.count)
                }
            }

            do {
                let path = distination.appendingPathComponent(file_url.lastPathComponent.replacingOccurrences(of: ".xlog", with: ".log"));
                if FileManager.default.fileExists(atPath: path.absoluteString.components(separatedBy: "://").last!) {
                    self.delegate?.updateDecodeMessage(message: "同名文件已存在，正在删除...")
                    try! FileManager.default.removeItem(at: path);
                    self.delegate?.updateDecodeMessage(message: "同名文件已删除")
                }
                try log_string.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                
                self.delegate?.updateDecodeMessage(message: "日志文件解码完成. file_name : \(path.lastPathComponent)")
                try? FileManager.default.removeItem(at: file_url)
                
                return true
            } catch {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
                self.isDecoding = false
                self.delegate?.updateDecodeMessage(message: "[Error] .log 日志文件写入错误");
                return false
            }
        } catch {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "decode_error"), object: nil)
            self.isDecoding = false
            self.delegate?.updateDecodeMessage(message: "[Error] .xlog 日志文件读取错误");
            return false
        }
    }
}


