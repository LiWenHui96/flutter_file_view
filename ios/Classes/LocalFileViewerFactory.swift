import UIKit

class LocalFileViewerFactory: NSObject, FlutterPlatformViewFactory {
  var _messenger: FlutterBinaryMessenger?
  
  init(messenger: FlutterBinaryMessenger) {
    super.init()
    self._messenger = messenger
  }
  
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
    
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return LocalFileViewer(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: _messenger!)
  }
}
