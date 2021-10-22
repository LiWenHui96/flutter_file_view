import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: Local file viewer
///            本地文件查看器
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/10
///

class FileLocalViewer extends StatefulWidget {
  const FileLocalViewer({
    Key? key,
    required this.localFilePath,
    this.unsupportedPlatformTip,
    this.nonexistentFileTip,
    this.openFailTip,
    this.loadingWidget,
    this.unsupportedTypeWidget,
  }) : super(key: key);

  ///
  /// Local file path
  ///
  /// 本地文件路径
  ///
  final String localFilePath;

  ///
  /// Platform hints are not supported
  /// This prompt is required because it only supports Android and iOS dual platforms and has not been adapted to the desktop platform and web
  ///
  /// 不支持平台的提示
  /// 因仅支持Android、iOS双平台，暂未进行桌面平台以及web的适配，故需要该提示
  ///
  final String? unsupportedPlatformTip;

  ///
  /// Prompt that the file under this [localFilePath] path does not exist
  ///
  /// 此[localFilePath]路径下的文件不存在的提示
  ///
  final String? nonexistentFileTip;

  ///
  /// Prompt of failure to open file
  ///
  /// 打开文件失败的提示
  ///
  final String? openFailTip;

  ///
  /// Widget showing loading status
  ///
  /// 加载状态的部件
  ///
  final Widget? loadingWidget;

  ///
  /// Unsupported file type widget
  ///
  /// 不支持的文件类型的部件
  ///
  final Widget? unsupportedTypeWidget;

  @override
  _FileLocalViewerState createState() => _FileLocalViewerState();
}

class _FileLocalViewerState extends State<FileLocalViewer> {
  EViewStatus eViewStatus = EViewStatus.loading;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((callback) {
      changeStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (eViewStatus == EViewStatus.loading) {
      return _buildLoadWidget();
    } else if (eViewStatus == EViewStatus.nonexistent) {
      // Check whether the file exists first
      return _buildNonexistentWidget();
    } else if (eViewStatus == EViewStatus.unsupporeedType) {
      return _buildUnSupportTypeWidget();
    } else if (eViewStatus == EViewStatus.engineFail) {
      return _buildEngineFailWidget();
    } else if (eViewStatus == EViewStatus.unsupporeedPlatform) {
      return _buildUnSupportPlatformWidget();
    } else if (eViewStatus == EViewStatus.fail) {
      return _buildFailWidget();
    } else if (eViewStatus == EViewStatus.success) {
      if (Platform.isAndroid) {
        return _createAndroidView();
      } else {
        return _createIosView();
      }
    } else {
      // Default display load widget
      return _buildLoadWidget();
    }
  }

  Widget _buildLoadWidget() {
    return widget.loadingWidget ??
        const Center(child: CupertinoActivityIndicator(radius: 14.0));
  }

  Widget _buildNonexistentWidget() {
    return showTipWidget(widget.nonexistentFileTip ?? '文件不存在');
  }

  Widget _buildUnSupportTypeWidget() {
    return widget.unsupportedTypeWidget ?? showTipWidget('不支持打开$fileType类型的文件');
  }

  Widget _buildEngineFailWidget() {
    return showTipWidget('引擎加载失败，请重启App');
  }

  Widget _buildUnSupportPlatformWidget() {
    return showTipWidget(widget.unsupportedPlatformTip ?? '当前仅支持Android、iOS平台');
  }

  Widget _buildFailWidget() {
    return showTipWidget(widget.openFailTip ?? '文件打开失败');
  }

  Widget _createAndroidView() {
    return AndroidView(
      viewType: viewName,
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {
        'filePath': filePath,
        'fileType': fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _createIosView() {
    return UiKitView(
      viewType: viewName,
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {
        'filePath': filePath,
        'fileType': fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  _onPlatformViewCreated(int id) async {
    MethodChannel _channel = MethodChannel('${channelName}_$id');

    bool flag = await _channel.invokeMethod('openFile');
    if (!flag) {
      _setStatus(EViewStatus.unsupporeedType);
    }
  }

  ///
  /// Widgets for presenting information
  ///
  /// 展示信息的部件
  ///
  Widget showTipWidget(String tip) {
    return Center(child: Text(tip));
  }

  ///
  /// Display different layouts by changing status
  ///
  /// 通过更改状态显示不同的布局
  ///
  Future<void> changeStatus() async {
    if (Platform.isAndroid || Platform.isIOS) {
      bool isExists = await FileTool.isExistsFile(filePath);

      if (isExists) {
        if (Platform.isAndroid) {
          EX5Status? eX5status = await FlutterFileView.getX5Status();
          if (eX5status == EX5Status.success) {
            _setStatus(EViewStatus.success);
          } else {
            _setStatus(EViewStatus.engineFail);
          }
        } else {
          _setStatus(EViewStatus.success);
        }
      } else {
        _setStatus(EViewStatus.nonexistent);
      }
    } else {
      _setStatus(EViewStatus.unsupporeedPlatform);
    }
  }

  _setStatus(EViewStatus e) {
    setState(() {
      if (mounted) eViewStatus = e;
    });
  }

  ///
  /// Path to file
  ///
  /// 文件路径
  ///
  String get filePath => widget.localFilePath;

  ///
  /// Type of file
  ///
  /// 文件类型
  ///
  String get fileType => FileTool.getFileType(filePath);
}
