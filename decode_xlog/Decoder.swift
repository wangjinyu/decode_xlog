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
                self.delegate?.updateDecodeMessage(message: "开始下载日志文件")
                self.downloadLogZipFile()
            } else {
                self.delegate?.updateDecodeMessage(message: "日志文件 url 不合法")
            }
        }
    }
    public func stopDecode() {
        self.isDecoding = false;
        print("停止解析");
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
                    _ = self.getXlogFilesWithZipFile(zipFilePath: (response.destinationURL)!);
                } else {
                    self.delegate?.updateDecodeMessage(message: "日志文件下载失败. 不是合法的日志文件 : \(filename)")
                }
            
            } else if response.result.isFailure {
                self.delegate?.updateDecodeMessage(message: "日志文件下载失败. erro : \(String(describing: response.error))")
            }
        })
    }
}

extension Decoder {
    fileprivate func getXlogFilesWithZipFile (zipFilePath:URL) -> [String] {
        do {
            
            let zip_file_name = zipFilePath.lastPathComponent
            let unzip_file_directory = zip_file_name.components(separatedBy: ".")[0]
            
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0];
            let fileURL = downloadsURL.appendingPathComponent("feedback_logs").appendingPathComponent(unzip_file_directory)
            self.delegate?.updateDecodeMessage(message: "开始解压日志文件. file_name : \(zip_file_name)")
            
            var file_names : [String] = [];
            
            try Zip.unzipFile(zipFilePath, destination: fileURL, overwrite: true, password: "", progress: { (progress) in
                if progress == 1.0 {
                    self.delegate?.updateDecodeMessage(message: "xlog 日志文件 解压完成. log file directory : \(String(describing: fileURL.absoluteString.components(separatedBy: "://").last!))")
                    //删除 zip 文件
                    try? FileManager.default.removeItem(at: zipFilePath)
                    
                    file_names = try! FileManager.default.contentsOfDirectory(atPath: fileURL.absoluteString.components(separatedBy: "://").last!)
                    
                    for file in file_names {
                        self.delegate?.updateDecodeMessage(message: "开始解码日志文件. file_name : \(file)")
                        let file_url = fileURL.appendingPathComponent(file)
                        let success = self.decode_xlog_file(file_url: file_url, distination: fileURL)
                        if success == true {
                            
                        }
                    }
                }
            })
            return file_names;
            
        } catch ZipError.unzipFail {
            self.delegate?.updateDecodeMessage(message: "日志文件解压失败 : \(ZipError.unzipFail)")
        } catch ZipError.fileNotFound {
            self.delegate?.updateDecodeMessage(message: "日志文件解压失败, 文件不存在 : \(ZipError.fileNotFound)")
        } catch {
            self.delegate?.updateDecodeMessage(message: "日志文件解压失败, 未知错误")
        }
        return []
    }
    
    fileprivate func decode_xlog_file(file_url : URL, distination: URL) -> Bool {
        do {
            let file_data = try Data.init(contentsOf: file_url)
            print("\(file_data)")
            
            let string :String = String.init(data: file_data.subdata(in: 13..<file_data.count), encoding: String.Encoding.ascii)!
            do {
                let path = distination.appendingPathComponent(file_url.lastPathComponent.replacingOccurrences(of: ".xlog", with: ".log"));
                try string.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                self.delegate?.updateDecodeMessage(message: "日志文件解码完成. file_name : \(path.lastPathComponent)")
                try? FileManager.default.removeItem(at: file_url)
                return true
            } catch  {
                self.delegate?.updateDecodeMessage(message: ".log 日志文件写入错误");
                return false
            }
        } catch  {
            self.delegate?.updateDecodeMessage(message: ".xlog 日志文件读取错误");
            return false
        }
    }
}


