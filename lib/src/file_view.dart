import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/src/enum/x5_status.dart';

import 'enum/view_type.dart';
import 'file_view_localizations.dart';
import 'file_view_tools.dart';
import 'flutter_file_view.dart';

/// @Describe: The view of file.
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/11

class FileView extends StatefulWidget {
  // ignore: public_member_api_docs
  const FileView({
    Key? key,
    required this.controller,
    this.placeholder,
    this.tipTextStyle,
    this.unSupportedPlatform,
    this.nonExistent,
    this.unSupportedType,
  }) : super(key: key);

  /// The [FileViewController] responsible for the file being rendered in this
  /// widget.
  final FileViewController controller;

  /// Widget displayed while the target is loading.
  final Widget? placeholder;

  /// The style of the text for the prompt.
  final TextStyle? tipTextStyle;

  /// Widget to display on unsupported platforms.
  ///
  /// This prompt is required because it only supports Android and iOS,
  /// and has not been adapted to desktop and web for the time being.
  final Widget? unSupportedPlatform;

  /// Widget displayed while the file  does not exist.
  final Widget? nonExistent;

  /// Widget displayed while the file is of an unsupported file types
  final Widget? unSupportedType;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  late FileViewLocalizations local = FileViewLocalizations.of(context);

  @override
  void initState() {
    widget.controller.initialize();
    widget.controller.addListener(_listener);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant FileView oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.controller.removeListener(_listener);
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();

    widget.controller.removeListener(_listener);
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.controller.value.viewType) {
      case ViewType.UNSUPPORTED_PLATFORM:
        return _buildUnSupportPlatformWidget();
      case ViewType.NON_EXISTENT:
        return _buildNonExistentWidget();
      case ViewType.UNSUPPORTED_FILETYPE:
        return _buildUnSupportTypeWidget();
      case ViewType.DONE:
        return _buildDoneWidget();
      // ignore: no_default_cases
      default:
        return _buildPlaceholderWidget();
    }
  }

  /// The layout to display when loading.
  Widget _buildPlaceholderWidget() {
    return widget.placeholder ??
        Center(
          child: CircularProgressIndicator(
            key: ValueKey<String>('FileView_${hashCode}_Placeholder'),
            value: widget.controller.value.progressValue,
          ),
        );
  }

  /// The layout to display when the platform is unsupported.
  Widget _buildUnSupportPlatformWidget() {
    return widget.unSupportedPlatform ??
        showTipWidget(local.unSupportedPlatformTip);
  }

  /// The layout to display when the file does not exist.
  Widget _buildNonExistentWidget() {
    return widget.nonExistent ?? showTipWidget(local.nonExistentTip);
  }

  /// The layout to display when the file type is unsupported.
  Widget _buildUnSupportTypeWidget() {
    return widget.unSupportedType ??
        showTipWidget(
          sprintf(
            local.unSupportedType,
            widget.controller.value.fileType ?? '',
          ),
        );
  }

  /// Widgets for presenting information
  Widget showTipWidget(String tip) {
    return Center(child: Text(tip, style: widget.tipTextStyle));
  }

  /// A replacement operation for [stringTf].
  String sprintf(String stringTf, String msg) {
    return stringTf.replaceAll('%s', msg);
  }

  /// The layout to display when complete.
  Widget _buildDoneWidget() {
    if (isAndroid) {
      return _createAndroidView();
    } else if (isIOS) {
      return UiKitView(
        viewType: viewName,
        creationParams: <String, String>{
          'filePath': widget.controller.value.filePath ?? '',
          'fileType': widget.controller.value.fileType ?? '',
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return _buildUnSupportPlatformWidget();
  }

  Widget _createAndroidView() {
    switch (widget.controller.value.x5status) {
      case X5Status.DONE:
        return AndroidView(
          viewType: viewName,
          creationParams: <String, dynamic>{
            'filePath': widget.controller.value.filePath,
            'fileType': widget.controller.value.fileType,
            'is_bar_show': widget.controller._androidViewConfig.isBarShow,
            'into_downloading':
                widget.controller._androidViewConfig.intoDownloading,
            'is_bar_animating':
                widget.controller._androidViewConfig.isBarAnimating,
          },
          onPlatformViewCreated: (int id) {
            MethodChannel('${channelName}_$id').invokeMethod<void>(
              'openFile',
              FlutterFileView.currentAndroidViewNumber++ == 0,
            );
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      case X5Status.ERROR:
        return showX5RetryWidget(local.engineFail);
      case X5Status.DOWNLOAD_SUCCESS:
        return showX5TipWidget(local.engineDownloadSuccess);
      case X5Status.DOWNLOAD_FAIL:
        return showX5RetryWidget(local.engineDownloadFail);
      case X5Status.DOWNLOADING:
        return showX5TipWidget(local.engineDownloading);
      case X5Status.DOWNLOAD_NON_REQUIRED:
        return showTipWidget(local.engineDownloadNonRequired);
      case X5Status.DOWNLOAD_OUT_OF_ONE:
        return showTipWidget(local.engineDownloadOutOfOne);
      case X5Status.INSTALL_SUCCESS:
        return showX5TipWidget(local.engineInstallSuccess);
      case X5Status.INSTALL_FAIL:
        return showX5RetryWidget(local.engineInstallFail);
      // ignore: no_default_cases
      default:
        return showX5TipWidget(local.engineLoading);
    }
  }

  /// Widgets for presenting information of x5Status.
  Widget showX5TipWidget(String tip) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            key: ValueKey<String>('FileView_${hashCode}_X5_Placeholder'),
            value: widget.controller.value.progressValue,
          ),
          const SizedBox(height: 20),
          Text(tip, style: widget.tipTextStyle),
        ],
      ),
    );
  }

  Widget showX5RetryWidget(String tip) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(tip, style: widget.tipTextStyle),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              widget.controller.initializeForAndroid();
            },
            child: Text(local.retry, style: widget.tipTextStyle),
          ),
        ],
      ),
    );
  }
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
    this.androidViewConfig,
    this.isDelExist = false,
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
    NetworkConfig? config,
    this.androidViewConfig,
    this.isDelExist = false,
  })  : dataSourceType = DataSourceType.network,
        package = null,
        networkConfig = config ?? NetworkConfig(),
        super(FileViewValue.uninitialized());

  /// Constructs a [FileViewController] preview a document from a file.
  FileViewController.file(
    File file, {
    this.androidViewConfig,
    this.isDelExist = false,
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

  /// HTTP headers used for the request to the [dataSource].
  /// Only for [FileViewController.network].
  /// Always empty for other document types.
  final NetworkConfig? networkConfig;

  /// The relevant parameters of TbsReaderView.
  final AndroidViewConfig? androidViewConfig;

  /// Whether to delete files with the same path.
  final bool isDelExist;

  /// Parameters supplied to _createAndroidView to use.
  AndroidViewConfig get _androidViewConfig =>
      androidViewConfig ?? AndroidViewConfig();

  /// Attempts to open the given [dataSource] and load metadata about
  /// the document.
  Future<void> initialize() async {
    if (!(isAndroid || isIOS)) {
      value = value.copyWith(viewType: ViewType.UNSUPPORTED_PLATFORM);
      return;
    }

    value = value.copyWith(viewType: ViewType.LOADING);

    /// The file to be used later.
    File? file;

    /// The name of the file.
    final String fileName = FileViewTools.getFileSaveKey(dataSource);

    /// The storage address of the file.
    final String filePath =
        '${await FileViewTools.getDirectoryPath()}$fileName';

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
      file = File(filePath)..createSync(recursive: true);

      if (dataSourceType == DataSourceType.asset) {
        final ByteData bd = await rootBundle.load(keyName);
        await file.writeAsBytes(bd.buffer.asUint8List());
      } else if (dataSourceType == DataSourceType.file) {
        await file.writeAsBytes(File(dataSource).readAsBytesSync());
      }
    }

    if (file != null && FileViewTools.fileExists(filePath)) {
      final String fileType = FileViewTools.getFileType(filePath);
      value = value.copyWith(fileType: fileType);

      if (FileViewTools.isSupportByType(fileType)) {
        value = value.copyWith(viewType: ViewType.DONE, filePath: filePath);

        if (isAndroid) {
          await initializeForAndroid();
        }
      } else {
        value = value.copyWith(viewType: ViewType.UNSUPPORTED_FILETYPE);
      }
    } else {
      value = value.copyWith(viewType: ViewType.NON_EXISTENT);
    }
  }

  /// Monitor the loading status of X5 kernel.
  StreamSubscription<X5Status>? x5StatusListener;

  /// Monitor the download status of X5 kernel.
  StreamSubscription<int>? downloadListener;

  /// Because Android uses the X5 engine, it needs to be operated separately.
  Future<void> initializeForAndroid() async {
    final X5Status x5Status = await FlutterFileView.x5Status();
    value = value.copyWith(x5status: x5Status);

    if (x5Status != X5Status.DONE) {
      if (x5Status == X5Status.NONE) {
        FlutterFileView.init();
      }

      x5StatusListener = FlutterFileView.initController.listen((_) {
        if (_ == X5Status.DOWNLOADING) {
          downloadListener = FlutterFileView.downlodController.listen((__) {
            value = value.copyWith(x5status: _, progressValue: __ / 100);
          });
        } else {
          value = value.copyWith(x5status: _);
        }
      });
    }
  }

  @override
  void dispose() {
    x5StatusListener?.cancel();
    downloadListener?.cancel();

    super.dispose();
  }
}

/// The viewType, filePath, fileType, downloadProgress, X5Status of a
/// [FileViewController].
class FileViewValue {
  /// Constructs a file with the given values. Only [viewType] is required.
  /// The rest will initialize with default values when unset.
  FileViewValue({
    required this.viewType,
    this.x5status = X5Status.NONE,
    this.filePath,
    this.fileType,
    this.progressValue,
  });

  /// Returns an instance for a file that hasn't been loaded.
  FileViewValue.uninitialized() : this(viewType: ViewType.NONE);

  /// The loaded state of the view.
  final ViewType viewType;

  /// The state of X5 kernel.
  final X5Status x5status;

  /// The path where the file is stored.
  final String? filePath;

  /// The type of storage of the file
  final String? fileType;

  /// The progress of the loading of [CircularProgressIndicator].
  final double? progressValue;

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWith].
  FileViewValue copyWith({
    ViewType? viewType,
    X5Status? x5status,
    String? filePath,
    String? fileType,
    double? progressValue,
  }) {
    return FileViewValue(
      viewType: viewType ?? this.viewType,
      x5status: x5status ?? this.x5status,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      progressValue: progressValue,
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
