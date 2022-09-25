import Flutter
import UIKit

let channelName = "flutter_file_view.io.channel/method"
let viewName = "flutter_file_view.io.view/local"

public class SwiftFlutterFileViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterFileViewPlugin()
    
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(FileViewFactory.init(messenger: registrar.messenger()), withId: viewName)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
      case "getTemporaryPath":
        result(FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).map(\.path).first)
        break
      default:
        result(FlutterMethodNotImplemented)
        break
    }
  }
}
