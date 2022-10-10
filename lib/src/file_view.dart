import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/src/enum/x5_status.dart';

import 'enum/view_type.dart';
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
      return Stack(
        children: <Widget>[
          UiKitView(
            viewType: viewName,
            creationParams: <String, String>{
              'filePath': widget.controller.value.filePath ?? '',
              'fileType': widget.controller.value.fileType ?? '',
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
          if ((widget.controller.value.progressForIOS ?? 0) < 100)
            _buildPlaceholderWidget(),
        ],
      );
    }

    return _buildUnSupportPlatformWidget();
  }

  Widget _createAndroidView() {
    switch (widget.controller.value.x5status) {
      case X5Status.DONE:
        final AndroidViewConfig config =
            widget.controller.androidViewConfig ?? AndroidViewConfig();

        return AndroidView(
          viewType: viewName,
          creationParams: <String, dynamic>{
            'filePath': widget.controller.value.filePath,
            'fileType': widget.controller.value.fileType,
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
      case X5Status.ERROR:
        return showTipWidget(local.engineFail);
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
            color: Theme.of(context).primaryColor,
            backgroundColor: widget.controller.value.progressValue != null
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
              widget.controller.initializeForAndroid();
            },
            child: Text(local.retry, style: widget.tipTextStyle),
          ),
        ],
      ),
    );
  }
}
