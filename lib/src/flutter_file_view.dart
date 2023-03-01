import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enum/view_status.dart';
import 'enum/x5_status.dart';
import 'file_view.dart';
import 'file_view_tools.dart';

/// @Describe: Inside the plugin, this is the class that contains all the tools.
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/11

class FlutterFileView {
  static const MethodChannel _channel = MethodChannel(channelName);

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

  /// 获取X5内核当前的状态。
  ///
  /// Get the current state of the X5 kernel.
  static Future<X5Status> get x5Status async {
    if (!isAndroid) {
      throw PlatformException(
        code: 'Unnecessary',
        details: 'The `x5Status` method of the flutter_file_view plugin is '
            'currently only used on the Android platform.',
      );
    }

    final int? i = await _channel.invokeMethod<int>('x5Status');
    return X5StatusExtension.getType(i);
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
}

/// The controller of [FileView].
///
/// The document is displayed in a Flutter app by creating a [FileView] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class FileViewController extends ValueNotifier<FileViewValue> {
  /// Constructs a [FileViewController] preview a document from an asset.
  ///
  /// The name of the asset is given by the [dataSource] argument and must not
  /// be null. The [package] argument must be non-null when the asset comes
  /// from a package and null otherwise.
  FileViewController.asset(
    this.dataSource, {
    this.package,
    this.customFileName,
    this.androidViewConfig,
    this.isDelExist = true,
  })  : dataSourceType = DataSourceType.asset,
        networkConfig = null,
        super(FileViewValue.uninitialized());

  /// Constructs a [FileViewController] preview a document from obtained from
  /// the network.
  ///
  /// The URI for the document is given by the [dataSource] argument and must
  /// not be null.
  FileViewController.network(
    this.dataSource, {
    this.customFileName,
    NetworkConfig? config,
    this.androidViewConfig,
    this.isDelExist = true,
  })  : dataSourceType = DataSourceType.network,
        package = null,
        networkConfig = config ?? NetworkConfig(),
        super(FileViewValue.uninitialized());

  /// Constructs a [FileViewController] preview a document from a file.
  FileViewController.file(
    File file, {
    this.customFileName,
    this.androidViewConfig,
    this.isDelExist = true,
  })  : dataSource = file.path,
        dataSourceType = DataSourceType.file,
        package = null,
        networkConfig = null,
        super(FileViewValue.uninitialized());

  /// The URI to the document file. This will be in different formats depending
  /// on the [DataSourceType] of the original document.
  final String dataSource;

  /// Describes the type of data source this [FileViewController]
  /// is constructed with.
  final DataSourceType dataSourceType;

  /// Only set for [FileViewController.asset] documents. The package that the
  /// asset was loaded from.
  final String? package;

  /// The name used to generate the key to obtain the asset. For local assets
  /// this is [dataSource], and for assets from packages the [dataSource] is
  /// prefixed 'packages/<package_name>/'.
  String get keyName =>
      package == null ? dataSource : 'packages/$package/$dataSource';

  /// Define the name of the file to be stored in the cache yourself.
  final String? customFileName;

  /// HTTP headers used for the request to the [dataSource].
  /// Only for [FileViewController.network].
  /// Always empty for other document types.
  final NetworkConfig? networkConfig;

  /// The relevant parameters of TbsReaderView.
  final AndroidViewConfig? androidViewConfig;

  /// Whether to delete files with the same path.
  final bool isDelExist;

  /// Attempts to open the given [dataSource] and load metadata about
  /// the document.
  Future<void> initialize() async {
    if (!(isAndroid || isIOS)) {
      value = value.copyWith(viewStatus: ViewStatus.UNSUPPORTED_PLATFORM);
      return;
    }

    FlutterFileView._channel.setMethodCallHandler(_handler);

    value = value.copyWith(viewStatus: ViewStatus.LOADING);

    /// The name of the file.
    final String fileName =
        FileViewTools.getFileSaveKey(dataSource, fileName: customFileName);

    /// The storage address of the file.
    final String filePath =
        '${await FileViewTools.getDirectoryPath()}$fileName';

    final String fileType = FileViewTools.getFileType(filePath);
    value = value.copyWith(fileType: fileType);

    if (FileViewTools.isSupportByType(fileType)) {
      value = value.copyWith(filePath: filePath);

      /// The file to be used later.
      File? file;

      /// If the file itself exists, it will be deleted.
      if (isDelExist && FileViewTools.fileExists(filePath)) {
        await File(filePath).delete();
      }

      if (dataSourceType == DataSourceType.network) {
        final bool flag = await FileViewTools.downloadFile(
          dataSource,
          filePath,
          onReceiveProgress: (int count, int total) {
            value = value.copyWith(progressValue: count / total);
          },
          config: networkConfig,
        );

        if (flag) {
          file = File(filePath);
        }
      } else {
        try {
          file = File(filePath)..createSync(recursive: true);

          if (dataSourceType == DataSourceType.asset) {
            final ByteData bd = await rootBundle.load(keyName);
            await file.writeAsBytes(bd.buffer.asUint8List());
          } else if (dataSourceType == DataSourceType.file) {
            await file.writeAsBytes(File(dataSource).readAsBytesSync());
          }
        } catch (e) {
          file = null;
        }
      }

      if (file != null && FileViewTools.fileExists(filePath)) {
        value = value.copyWith(viewStatus: ViewStatus.DONE);

        if (isAndroid) {
          await initializeForAndroid();
        } else if (isIOS) {
          await initializeForIOS();
        }
      } else {
        value = value.copyWith(viewStatus: ViewStatus.NON_EXISTENT);
      }
    } else {
      value = value.copyWith(viewStatus: ViewStatus.UNSUPPORTED_FILETYPE);
    }
  }

  /// Monitor the loading status of X5 kernel.
  StreamController<X5Status>? _initController;

  /// Monitor the download status of X5 kernel.
  /// Monitor the progress of the iOS loading.
  StreamController<num>? _progressController;

  /// Monitor the loading status of X5 kernel.
  StreamSubscription<X5Status>? _x5StatusListener;

  /// Monitor the download status of X5 kernel.
  /// Monitor the progress of the iOS loading.
  StreamSubscription<num>? _progressListener;

  /// Because Android uses the X5 engine, it needs to be operated separately.
  Future<void> initializeForAndroid() async {
    final X5Status x5Status = await FlutterFileView.x5Status;
    value = value.copyWith(x5status: x5Status);

    if (x5Status != X5Status.DONE) {
      _initController ??= StreamController<X5Status>.broadcast();

      _x5StatusListener = _initController?.stream.listen((_) {
        if (_ == X5Status.DOWNLOADING) {
          _progressController ??= StreamController<num>.broadcast();

          _progressListener = _progressController?.stream.listen((__) {
            value = value.copyWith(x5status: _, progressValue: __ / 100);
          });
        } else {
          value = value.copyWith(x5status: _);
        }
      });
    }
  }

  /// Used to monitor the progress of iOS loading.
  Future<void> initializeForIOS() async {
    _progressController ??= StreamController<num>.broadcast();

    _progressListener = _progressController?.stream.listen((_) {
      value = value.copyWith(progressForIOS: _);
    });
  }

  /// Delete Files.
  void deleteFile() {
    final File file = File(value.filePath ?? '');

    if (isDelExist && file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case 'x5Status':
        _initController?.add(X5StatusExtension.getType(call.arguments as int));
        break;
      case 'x5DownloadProgress':
      case 'onProgress':
        _progressController?.add(num.tryParse(call.arguments.toString()) ?? 0);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    deleteFile();

    _initController?.close();
    _progressController?.close();
    _x5StatusListener?.cancel();
    _progressListener?.cancel();

    super.dispose();
  }
}

/// The viewStatus, filePath, fileType, downloadProgress, X5Status of a
/// [FileViewController].
class FileViewValue {
  /// Constructs a file with the given values. Only [viewStatus] is required.
  /// The rest will initialize with default values when unset.
  FileViewValue({
    required this.viewStatus,
    this.x5status = X5Status.NONE,
    this.filePath,
    this.fileType,
    this.progressValue,
    this.progressForIOS,
  });

  /// Returns an instance for a file that hasn't been loaded.
  FileViewValue.uninitialized() : this(viewStatus: ViewStatus.NONE);

  /// The loaded state of the view.
  final ViewStatus viewStatus;

  /// The state of X5 kernel.
  final X5Status x5status;

  /// The path where the file is stored.
  final String? filePath;

  /// The type of storage of the file
  final String? fileType;

  /// The progress of the loading of [CircularProgressIndicator].
  final double? progressValue;

  /// Invoked when a page is loading.
  final num? progressForIOS;

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWith].
  FileViewValue copyWith({
    ViewStatus? viewStatus,
    X5Status? x5status,
    String? filePath,
    String? fileType,
    double? progressValue,
    num? progressForIOS,
  }) {
    return FileViewValue(
      viewStatus: viewStatus ?? this.viewStatus,
      x5status: x5status ?? this.x5status,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      progressValue: progressValue,
      progressForIOS: progressForIOS,
    );
  }
}

/// The way in which the document was originally loaded.
///
/// This has nothing to do with the document's file type. It's just the place
/// from which the document is fetched from.
enum DataSourceType {
  /// The document was included in the app's asset files.
  asset,

  /// The document was downloaded from the internet.
  network,

  /// The document was loaded off of the local filesystem.
  file,
}

/// HTTP headers used for the request to the `dataSource`.
/// Only for [FileViewController.network].
/// Always empty for other document types.
class NetworkConfig {
  // ignore: public_member_api_docs
  NetworkConfig({
    this.queryParameters,
    this.cancelToken,
    this.deleteOnError,
    this.lengthHeader,
    this.data,
    this.options,
  });

  /// [Dio.download] `queryParameters`
  final Map<String, dynamic>? queryParameters;

  /// [Dio.download] `cancelToken`
  final CancelToken? cancelToken;

  /// [Dio.download] `deleteOnError`
  final bool? deleteOnError;

  /// [Dio.download] `lengthHeader`
  final String? lengthHeader;

  /// [Dio.download] `data`
  final dynamic data;

  /// [Dio.download] `options`
  final Options? options;
}

/// The relevant parameters of TbsReaderView.
class AndroidViewConfig {
  // ignore: public_member_api_docs
  AndroidViewConfig({
    this.isBarShow = false,
    this.intoDownloading = false,
    this.isBarAnimating = false,
  });

  /// The `is_bar_show` of TbsReaderView
  final bool isBarShow;

  /// The `into_downloading` of TbsReaderView
  final bool intoDownloading;

  /// The `is_bar_animating` of TbsReaderView
  final bool isBarAnimating;
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
