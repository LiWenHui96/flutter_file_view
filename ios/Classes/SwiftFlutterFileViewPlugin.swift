import Flutter
import UIKit

let channelName = "flutter_file_view.io.channel/method"
let viewName = "flutter_file_view.io.view/local"

public class SwiftFlutterFileViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterFileViewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(LocalFileViewerFactory.init(messenger: registrar.messenger()), withId: viewName)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
