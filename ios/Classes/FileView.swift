//
//  FileView.swift
//  flutter_file_view
//
//  Created by LiWeNHuI on 2021/10/22.
//

import UIKit

class FileView: NSObject, FlutterPlatformView {

  var wkWebView: FileViewWKWebView
  
  init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
    let args = args as! [String: String]
    
    self.wkWebView = FileViewWKWebView.init(frame: frame, fileType: args["fileType"]!.lowercased())
    
    super.init()
    
    self.openFile(filePath: args["filePath"]!, webView: self.wkWebView)
  }
  
  func openFile(filePath: String, webView: FileViewWKWebView)  {
    let url = URL.init(fileURLWithPath: filePath)

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
