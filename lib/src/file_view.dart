import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enum/view_status.dart';
import 'enum/x5_status.dart';
import 'file_view_localizations.dart';
import 'flutter_file_view.dart';

/// @Describe: The view of file.
///
/// @Author: LiWeNHuI
/// @Date: 2022/10/10

/// The view of file.
class FileView extends StatefulWidget {
  // ignore: public_member_api_docs
  const FileView({
    Key? key,
    required this.controller,
    this.onCustomViewStatusBuilder,
    this.onCustomX5StatusBuilder,
    this.tipTextStyle,
    this.buttonTextStyle,
  }) : super(key: key);

  /// The [FileViewController] responsible for the file being rendered in this
  /// widget.
  final FileViewController controller;

  /// According to different states, display the corresponding layout.
  final OnCustomViewStatusBuilder? onCustomViewStatusBuilder;

  /// According to different states, display the corresponding layout.
  final OnCustomX5StatusBuilder? onCustomX5StatusBuilder;

  /// The style of the text for the prompt.
  final TextStyle? tipTextStyle;

  /// The style of the text for button.
  final TextStyle? buttonTextStyle;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  late FileViewLocalizations local = FileViewLocalizations.of(context);

  @override
  void initState() {
    controller.initialize();
    controller.addListener(_listener);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant FileView oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.controller.removeListener(_listener);
    controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();

    controller.removeListener(_listener);
  }

  @override
  void dispose() {
    FlutterFileView.currentAndroidViewNumber = 0;

    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (value.viewStatus == ViewStatus.DONE) {
      return _buildDoneWidget();
    }

    Widget? child =
        widget.onCustomViewStatusBuilder?.call(context, value.viewStatus);

    if (value.viewStatus == ViewStatus.UNSUPPORTED_PLATFORM) {
      child ??= _buildUnSupportPlatformWidget();
    } else if (value.viewStatus == ViewStatus.NON_EXISTENT) {
      child ??= _buildNonExistentWidget();
    } else if (value.viewStatus == ViewStatus.UNSUPPORTED_FILETYPE) {
      child ??= _buildUnSupportTypeWidget();
    } else {
      child ??= _buildPlaceholderWidget();
    }

    return child;
  }

  /// The layout to display when the platform is unsupported.
  ///
  /// This prompt is required because it only supports Android and iOS,
  /// and has not been adapted to desktop and web for the time being.
  Widget _buildUnSupportPlatformWidget() {
    return showTipWidget(local.unSupportedPlatformTip);
  }

  /// The layout to display when the file does not exist.
  Widget _buildNonExistentWidget() {
    return showTipWidget(local.nonExistentTip);
  }

  /// The layout to display when the file type is unsupported.
  Widget _buildUnSupportTypeWidget() {
    return showTipWidget(sprintf(local.unSupportedType, value.fileType ?? ''));
  }

  /// Widgets for presenting information
  Widget showTipWidget(String tip) {
    return Center(child: Text(tip, style: widget.tipTextStyle));
  }

  /// The layout to display when complete.
  Widget _buildDoneWidget() {
    if (isAndroid) {
      return _createAndroidView();
    } else if (isIOS) {
      return Stack(
        children: <Widget>[
          UiKitView(
            viewType: viewName,
            creationParams: <String, String>{
              'filePath': value.filePath ?? '',
              'fileType': value.fileType ?? '',
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
          if ((value.progressForIOS ?? 0) < 100) _buildPlaceholderWidget(),
        ],
      );
    }

    return _buildUnSupportPlatformWidget();
  }

  Widget _createAndroidView() {
    if (value.x5status == X5Status.DONE) {
      final AndroidViewConfig config =
          controller.androidViewConfig ?? AndroidViewConfig();

      return AndroidView(
        viewType: viewName,
        creationParams: <String, dynamic>{
          'filePath': value.filePath,
          'fileType': value.fileType,
          'is_bar_show': config.isBarShow,
          'into_downloading': config.intoDownloading,
          'is_bar_animating': config.isBarAnimating,
        },
        onPlatformViewCreated: (int id) {
          MethodChannel('${channelName}_$id').invokeMethod<void>(
            'openFile',
            FlutterFileView.currentAndroidViewNumber++ == 0,
          );
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    Widget? child =
        widget.onCustomX5StatusBuilder?.call(context, value.x5status);

    if (value.x5status == X5Status.ERROR) {
      child ??= showX5RetryWidget(local.engineFail);
    } else if (value.x5status == X5Status.DOWNLOAD_SUCCESS) {
      child ??= showX5TipWidget(local.engineDownloadSuccess);
    } else if (value.x5status == X5Status.DOWNLOAD_FAIL) {
      child ??= showX5RetryWidget(local.engineDownloadFail);
    } else if (value.x5status == X5Status.DOWNLOADING) {
      child ??= showX5TipWidget(local.engineDownloading);
    } else if (value.x5status == X5Status.DOWNLOAD_NON_REQUIRED) {
      child ??= showTipWidget(local.engineDownloadNonRequired);
    } else if (value.x5status == X5Status.DOWNLOAD_CANCEL_NOT_WIFI) {
      child ??= showX5RetryWidget(local.engineDownloadCancelNotWifi);
    } else if (value.x5status == X5Status.DOWNLOAD_OUT_OF_ONE) {
      child ??= showTipWidget(local.engineDownloadOutOfOne);
    } else if (value.x5status == X5Status.DOWNLOAD_CANCEL_REQUESTING) {
      child ??= showX5TipWidget(local.engineDownloadCancelRequesting);
    } else if (value.x5status == X5Status.DOWNLOAD_NO_NEED_REQUEST) {
      child ??= showX5RetryWidget(local.engineDownloadNoNeedRequest);
    } else if (value.x5status == X5Status.DOWNLOAD_FLOW_CANCEL) {
      child ??= showX5TipWidget(local.engineDownloadFlowCancel);
    } else if (value.x5status == X5Status.INSTALL_SUCCESS) {
      child ??= showX5TipWidget(local.engineInstallSuccess);
    } else if (value.x5status == X5Status.INSTALL_FAIL) {
      child ??= showX5RetryWidget(local.engineInstallFail);
    } else {
      child ??= showX5TipWidget(local.engineLoading);
    }

    return child;
  }

  /// The layout to display when loading.
  Widget _buildPlaceholderWidget() {
    return Center(
      child: CircularProgressIndicator(
        key: ValueKey<String>('FileView_${hashCode}_Placeholder'),
        value: value.progressValue,
      ),
    );
  }

  /// Widgets for presenting information of x5Status.
  Widget showX5TipWidget(String tip) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            key: ValueKey<String>('FileView_${hashCode}_X5_Placeholder'),
            value: value.progressValue,
            color: Theme.of(context).primaryColor,
            backgroundColor: value.progressValue != null
                ? Theme.of(context).primaryColorLight
                : null,
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
              FlutterFileView.init();
              controller.initializeForAndroid();
            },
            child: Text(local.retry, style: widget.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  /// A replacement operation for [stringTf].
  String sprintf(String stringTf, String msg) {
    return stringTf.replaceAll('%s', msg);
  }

  FileViewController get controller => widget.controller;

  FileViewValue get value => controller.value;
}

/// According to [status], display different layouts.
///
/// In state [ViewStatus.DONE], the layout cannot be customized.
typedef OnCustomViewStatusBuilder = Widget? Function(
  BuildContext context,
  ViewStatus status,
);

/// According to [status], display different layouts.
///
/// In state [X5Status.DONE], the layout cannot be customized.
typedef OnCustomX5StatusBuilder = Widget? Function(
  BuildContext context,
  X5Status status,
);
