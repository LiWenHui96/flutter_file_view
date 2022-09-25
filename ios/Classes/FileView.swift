import UIKit
import WebKit

class FileView: NSObject, FlutterPlatformView {

  var _webView: WKWebView?
  var _xlsWebView: WKWebView?
  
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
    self.fileType = args["fileType"]!
    
    self._webView = WKWebView.init(frame: frame)

    let configuration = WKWebViewConfiguration()
    let userScript = WKUserScript(source: xlsJsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    configuration.userContentController.addUserScript(userScript)
    self._xlsWebView = WKWebView.init(frame: frame, configuration: configuration)
    
    self.openFile(filePath: args["filePath"]!, webView: self.isXls() ? self._xlsWebView! : self._webView!)
  }
  
  func openFile(filePath: String, webView: WKWebView)  {
    let url = URL.init(fileURLWithPath: filePath)
    
    if #available(iOS 9.0, *) {
      webView.loadFileURL(url, allowingReadAccessTo: url)
    } else {
      let request = URLRequest.init(url: url)
      webView.load(request)
    }
  }
  
  func isXls() -> Bool {
    let type = fileType.lowercased()
    return type == "xls" || type == "xlsx"
  }
  
  func view() -> UIView {
    if (isXls()) {
      return _xlsWebView!
    } else {
      return _webView!
    }
  }
}
