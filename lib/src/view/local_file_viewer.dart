import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe: Local file viewer
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class LocalFileViewer extends StatefulWidget {
  const LocalFileViewer({
    Key? key,
    required this.filePath,
    this.placeholder,
    this.unsupportedPlatformWidget,
    this.nonExistentWidget,
    this.unsupportedTypeWidget,
    this.isBarShow = false,
    this.intoDownloading = false,
    this.isBarAnimating = false,
  }) : super(key: key);

  /// Path to local file
  final String filePath;

  /// Widget displayed while the target [filePath] is loading.
  final Widget? placeholder;

  /// Widget displayed on unsupported platforms
  /// This prompt is required because it only supports Android and iOS, and has not been adapted to desktop and web for the time being.
  final Widget? unsupportedPlatformWidget;

  /// Widget displayed while the file with path [filePath] does not exist
  final Widget? nonExistentWidget;

  /// Widget displayed while the file is of an unsupported file types
  final Widget? unsupportedTypeWidget;

  /// The attributes of TbsReaderView
  final bool isBarShow;
  final bool intoDownloading;
  final bool isBarAnimating;

  @override
  State<LocalFileViewer> createState() => _LocalFileViewerState();
}

class _LocalFileViewerState extends State<LocalFileViewer> {
  late ViewerLocalizations local = ViewerLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ViewType>(
      future: getViewType(),
      initialData: ViewType.none,
      builder: (BuildContext context, AsyncSnapshot<ViewType> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          switch (snapshot.data ?? ViewType.none) {
            case ViewType.unsupported_platform:
              return _buildUnSupportPlatformWidget();
            case ViewType.non_existent:
              return _buildNonexistentWidget();
            case ViewType.unsupported_type:
              return _buildUnsupportTypeWidget();
            case ViewType.engine_loading:
              return _buildEngineLoadingWidget();
            case ViewType.engine_fail:
              return _buildEngineFailWidget();
            case ViewType.done:
              if (Platform.isAndroid) {
                return _createAndroidView();
              } else {
                return _createIosView();
              }
            case ViewType.none:
              return _buildPlaceholderWidget();
          }
        }

        return _buildPlaceholderWidget();
      },
    );
  }

  Widget _buildPlaceholderWidget() {
    return widget.placeholder ?? baseIndicator(context);
  }

  Widget _buildUnSupportPlatformWidget() {
    return widget.unsupportedPlatformWidget ??
        showTipWidget(local.unsupportedPlatformTip);
  }

  Widget _buildNonexistentWidget() {
    return widget.nonExistentWidget ?? showTipWidget(local.nonExistentTip);
  }

  Widget _buildUnsupportTypeWidget() {
    return widget.unsupportedTypeWidget ??
        showTipWidget(sprintf(local.unsupportedType, fileType));
  }

  Widget _buildEngineLoadingWidget() {
    return showTipWidget(local.engineLoading);
  }

  Widget _buildEngineFailWidget() {
    return showTipWidget(local.engineFail);
  }

  Widget _createAndroidView() {
    return AndroidView(
      viewType: viewName,
      creationParams: <String, dynamic>{
        'filePath': filePath,
        'fileType': fileType,
        'is_bar_show': widget.isBarShow,
        'into_downloading': widget.intoDownloading,
        'is_bar_animating': widget.isBarAnimating,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _createIosView() {
    return UiKitView(
      viewType: viewName,
      creationParams: <String, String>{
        'filePath': filePath,
        'fileType': fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  /// Widgets for presenting information
  Widget showTipWidget(String tip) {
    return Center(child: Text(tip));
  }

  /// Display different layouts by changing status
  Future<ViewType> getViewType() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (FileTool.isExistsFile(filePath)) {
        if (FileTool.isSupportOpen(fileType)) {
          if (Platform.isAndroid) {
            final X5Status? eX5status = await FlutterFileView.getX5Status();
            if (eX5status == X5Status.done) {
              return ViewType.done;
            } else if (eX5status == X5Status.error) {
              return ViewType.engine_fail;
            } else {
              FlutterFileView.initController.listen((X5Status e) async {
                if (e == X5Status.done) {
                  setState(() {});
                } else {
                  await FlutterFileView.initX5();
                  setState(() {});
                }
              });

              return ViewType.engine_loading;
            }
          } else {
            return ViewType.done;
          }
        } else {
          return ViewType.unsupported_type;
        }
      } else {
        return ViewType.non_existent;
      }
    } else {
      return ViewType.unsupported_platform;
    }
  }

  String sprintf(String stringtf, String msg) {
    return stringtf.replaceAll(r'%s', msg);
  }

  String get filePath => widget.filePath;

  String get fileType => FileTool.getFileType(filePath);
}
