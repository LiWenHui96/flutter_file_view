import UIKit
import WebKit

class FileView: NSObject, FlutterPlatformView {

  var _webView: WKWebView?
  var _xlsWebView: WKWebView?
  
  // 暂时放弃利用 QuickLook 实现
  // var controller: FileViewController = FileViewController()
  
  let supportFileType = ["docx","doc","xlsx","xls","pptx","ppt","pdf","txt","jpg","jpeg","png"]
  
  let xlsJsString = """
      var script = document.createElement('meta');\
      script.name = 'viewport';\
      script.content="width=device-width, initial-scale=1.0, minimum-scale=1.0, user-scalable=yes";\
      document.getElementsByTagName('head')[0].appendChild(script);
      """

  var fileType: String = ""
  
  init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
    super.init()
    
    let args = args as! [String: String]
    let filePath = args["filePath"]!
    self.fileType = args["fileType"]!
    
    let channel = FlutterMethodChannel(name: channelName + "_\(viewId)", binaryMessenger: messenger)
    
    channel.setMethodCallHandler { (call, result) in
      if call.method == "openFile" {
        if self.isSupportOpen() {
          self.openFile(filePath: filePath, webView: self.isXls() ? self._xlsWebView! : self._webView!)
          
          result(true)
        } else {
          result(false)
        }
        return
      }
    }
    
    self._webView = WKWebView.init(frame: frame)

    let configuration = WKWebViewConfiguration()
    let userScript = WKUserScript(source: xlsJsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    configuration.userContentController.addUserScript(userScript)
    self._xlsWebView = WKWebView.init(frame: frame, configuration: configuration)
  }
  
  func openFile(filePath: String, webView: WKWebView)  {
    // self.controller.setFilePath(filePath: filePath)
    
    let url = URL.init(fileURLWithPath: filePath)
    
    if #available(iOS 9.0, *) {
      webView.loadFileURL(url, allowingReadAccessTo: url)
    } else {
      let request = URLRequest.init(url: url)
      webView.load(request)
    }
  }

  func isSupportOpen() -> Bool {
    if supportFileType.contains(fileType.lowercased()) {
      return true
    }

    return false
  }
  
  func isXls() -> Bool {
    let type = fileType.lowercased()
    
    return type == "xls" || type == "xlsx"
  }
  
  func view() -> UIView {
    // return controller.view
    
    if (isXls()) {
      return _xlsWebView!
    } else {
      return _webView!
    }
  }
}
