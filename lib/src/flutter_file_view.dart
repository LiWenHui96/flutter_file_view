import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'enum/x5_status.dart';

/// @Describe: Inside the plugin, this is the class that contains all the tools.
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/11

class FlutterFileView {
  static final MethodChannel _channel = const MethodChannel(channelName)
    ..setMethodCallHandler(_handler);

  static final StreamController<X5Status> _initController =
      StreamController<X5Status>.broadcast();

  static final StreamController<int> _downloadController =
      StreamController<int>.broadcast();

  /// Monitor the loading status of X5 kernel.
  static Stream<X5Status> get initController => _initController.stream;

  /// Monitor the download status of X5 kernel.
  static Stream<int> get downlodController => _downloadController.stream;

  /// 因为 Android 使用 腾讯X5 内核作为支撑，所以在开始使用前需要进行初始化的操作。
  ///
  /// 而 iOS 因其 WKWebView 本身可对文件进行查看，故无需进行初始化的操作。
  ///
  /// 考虑到可能存在的情况，如：
  /// MaterialApp(
  ///   theme: ThemeData(platform: TargetPlatform.iOS),
  /// )
  /// 等，不再采用 [Platform.isAndroid] 的方式进行判断。
  ///
  /// [canDownloadWithoutWifi] 是否开启在非Wifi环境下下载，默认为 true。
  /// [canOpenDex2Oat] 是否开启TBS的 “dex2oat优化方案”，默认为 true。请在项目中的
  /// `AndroidManifest.xml` 添加相关代码，详情查看 `README.md` 。
  ///
  /// Because Android uses the Tencent X5 kernel as support, it needs to be
  /// initialized before starting to use.
  ///
  /// For iOS, because WKWebView itself can view the file, there is no need to
  /// initialize it.
  ///
  /// Considering possible situations, such as:
  /// MaterialApp(
  ///   theme: ThemeData(platform: TargetPlatform.iOS),
  /// )
  /// etc., the [Platform.isAndroid] method is no longer used for judgment.
  ///
  /// [canDownloadWithoutWifi] Whether to enable downloading in non-Wifi
  /// environment, the default is true.
  /// [canOpenDex2Oat] Whether to enable the "dex2oat optimization scheme"
  /// of TBS, the default is true. Please add relevant code to
  /// `AndroidManifest.xml` in the project, see `README.md` for details.
  static void init({
    bool canDownloadWithoutWifi = true,
    bool canOpenDex2Oat = true,
  }) {
    if (isAndroid) {
      _channel.invokeMethod<void>('init', <String, bool>{
        'canDownloadWithoutWifi': canDownloadWithoutWifi,
        'canOpenDex2Oat': canOpenDex2Oat,
      });
    }
  }

  /// 获取当前X5内核的状态。
  ///
  /// Get the current state of the X5 kernel.
  static Future<X5Status> x5Status() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw PlatformException(
        code: 'Unnecessary',
        details: 'The `x5Status` method of the flutter_file_view plugin is '
            'currently only used on the Android platform.',
      );
    }

    final int? i = await _channel.invokeMethod<int>('x5Status');
    return X5StatusExtension.getType(i ?? -1);
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  ///
  /// On iOS, this uses the `NSCachesDirectory` API.
  ///
  /// On Android, this uses the `getCacheDir` API on the context.
  ///
  /// Throws a `MissingPlatformDirectoryException` if the system is unable to
  /// provide the directory.
  static Future<Directory> getTemporaryDirectory() async {
    final String? path = await _channel.invokeMethod('getTemporaryPath');

    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get temporary directory',
      );
    }
    return Directory(path);
  }

  /// The number of currently open views.
  static int currentAndroidViewNumber = 0;

  static Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case 'x5Status':
        _initController.add(X5StatusExtension.getType(call.arguments as int));
        break;
      case 'x5DownloadProgress':
        _downloadController.add(call.arguments as int);
        break;
      default:
        break;
    }
  }
}

/// An exception thrown when a directory that should always be available on
/// the current platform cannot be obtained.
class MissingPlatformDirectoryException implements Exception {
  /// Creates a new exception
  MissingPlatformDirectoryException(this.message, {this.details});

  /// The explanation of the exception.
  final String message;

  /// Added details, if any.
  ///
  /// E.g., an error object from the platform implementation.
  final Object? details;

  @override
  String toString() {
    final String detailsAddition = details == null ? '' : ': $details';
    return 'MissingPlatformDirectoryException($message)$detailsAddition';
  }
}

/// The package name of the plugin.
const String packageName = 'flutter_file_view';

/// Directory name to use for file caching.
const String cacheKey = 'libCacheFileData';

/// The name of the channel used by the plugin.
const String channelName = 'flutter_file_view.io.channel/method';

/// The name of the view used by the plugin.
const String viewName = 'flutter_file_view.io.view/local';

/// Whether the operating system is a version of
/// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29).
bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

/// Whether the operating system is a version of
/// [iOS](https://en.wikipedia.org/wiki/IOS).
bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
