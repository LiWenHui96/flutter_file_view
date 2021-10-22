import Flutter
import UIKit

let channelName = "flutter_file_view.io.method"
let viewName = "plugins.file_local_view/view"

public class SwiftFlutterFileViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterFileViewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(FileViewFactory.init(messenger: registrar.messenger()), withId: viewName)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
