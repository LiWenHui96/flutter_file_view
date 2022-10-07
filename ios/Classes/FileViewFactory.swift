//
//  FileViewFactory.swift
//  flutter_file_view
//
//  Created by LiWeNHuI on 2021/10/22.
//

import UIKit

class FileViewFactory: NSObject, FlutterPlatformViewFactory {
  var _messenger: FlutterBinaryMessenger?
  
  init(messenger: FlutterBinaryMessenger) {
    super.init()
    self._messenger = messenger
  }
  
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
    
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return FileView(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: _messenger!)
  }
}
