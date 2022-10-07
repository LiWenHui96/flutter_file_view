//
//  FileViewWKWebView.swift
//  flutter_file_view
//
//  Created by LiWeNHuI on 2022/10/7.
//

import UIKit
import WebKit

class FileViewWKWebView : WKWebView {
  let xlsJsString = """
      var script = document.createElement('meta');\
      script.name = 'viewport';\
      script.content="width=device-width, initial-scale=1.0, minimum-scale=1.0, user-scalable=yes";\
      document.getElementsByTagName('head')[0].appendChild(script);
      """
  
  init(frame: CGRect, fileType: String) {
    let configuration = WKWebViewConfiguration()
    
    if (fileType == "xls" || fileType == "xlsx") {
      let userScript = WKUserScript(source: xlsJsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
      configuration.userContentController.addUserScript(userScript)
    }
    
    super.init(frame: frame, configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
