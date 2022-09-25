import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe: File view for Android.
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/22

class FileViewAndroid extends StatefulWidget {
  // ignore: public_member_api_docs
  const FileViewAndroid({
    Key? key,
    required this.filePath,
    required this.fileType,
    this.isBarShow = false,
    this.intoDownloading = false,
    this.isBarAnimating = false,
  }) : super(key: key);

  /// 文件的路径。
  ///
  /// The path to the file.
  final String filePath;

  /// 文件的类型。
  ///
  /// The type to the file.
  final String fileType;

  /// The `is_bar_show` of TbsReaderView
  final bool isBarShow;

  /// The `into_downloading` of TbsReaderView
  final bool intoDownloading;

  /// The `is_bar_animating` of TbsReaderView
  final bool isBarAnimating;

  @override
  State<FileViewAndroid> createState() => _FileViewAndroidState();
}

class _FileViewAndroidState extends State<FileViewAndroid> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget _createView() {
    return AndroidView(
      viewType: viewName,
      creationParams: <String, dynamic>{
        'filePath': widget.filePath,
        'fileType': widget.fileType,
        'is_bar_show': widget.isBarShow,
        'into_downloading': widget.intoDownloading,
        'is_bar_animating': widget.isBarAnimating,
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
}
