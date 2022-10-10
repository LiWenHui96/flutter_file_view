//
//  FileView.swift
//  flutter_file_view
//
//  Created by LiWeNHuI on 2021/10/22.
//

import UIKit

class FileView: NSObject, FlutterPlatformView {

  var wkWebView: FileViewWKWebView
  
  var channel: FlutterMethodChannel
  
  let onObserverKey = "estimatedProgress"
  
  init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
    let args = args as! [String: String]
    
    self.wkWebView = FileViewWKWebView.init(frame: frame, fileType: args["fileType"]!.lowercased())
    
    self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

    super.init()
    
    self.openFile(filePath: args["filePath"]!, webView: self.wkWebView)
  }
  
  deinit {
    self.wkWebView.removeObserver(self, forKeyPath: onObserverKey)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == onObserverKey {
      let newValue = change?[NSKeyValueChangeKey.newKey] ?? 0 // newValue is anywhere between 0.0 and 1.0
      let newValueAsInt = Int((newValue as AnyObject).floatValue * 100) // Anywhere between 0 and 100
      
      channel.invokeMethod("onProgress", arguments: NSNumber(value: newValueAsInt))
    }
  }
  
  func openFile(filePath: String, webView: FileViewWKWebView)  {
    let url = URL.init(fileURLWithPath: filePath)
    
    webView.addObserver(self, forKeyPath: onObserverKey, options: .new, context: nil)
    
    // 先进行NSUTF8StringEncoding编码
    var body = try? String(contentsOf: url, encoding: String.Encoding.utf8)
    if (body == nil) {
      // 如果没有编码成功再尝试GB_18030_2000编码
      let encode = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
      let encoding = String.Encoding.init(rawValue: encode)
      body = try? String(contentsOf: url, encoding: encoding)
    }

    if let body = body {
      webView.loadHTMLString(body, baseURL: nil)
      return
    }
    
    if #available(iOS 9.0, *) {
      webView.loadFileURL(url, allowingReadAccessTo: url)
    } else {
      let request = URLRequest.init(url: url)
      webView.load(request)
    }
  }
  
  func view() -> UIView {
    return wkWebView
  }
}
