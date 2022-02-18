import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe:
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/14

class FlutterFileView {
  static final MethodChannel _channel = const MethodChannel(channelName)
    ..setMethodCallHandler(_handler);

  static final StreamController<X5Status> _initController =
      StreamController<X5Status>.broadcast();

  static Stream<X5Status> get initController => _initController.stream;

  static Future<String?> get platformVersion async =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<void> initX5() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod<void>('manualInitX5');
    }
  }

  static Future<X5Status?> getX5Status() async {
    if (Platform.isAndroid) {
      final int? i = await _channel.invokeMethod<int>('getX5Status');
      return X5StatusExtension.getType(i ?? -1);
    }
    return null;
  }

  static Future<void> downloadFile(
    String fileUrl,
    String filePath, {
    required Function(DownloadStatus value) callback,
    ProgressCallback? onProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool? deleteOnError,
    String? lengthHeader,
    dynamic data,
    Options? options,
  }) async =>
      DownloadTool().downloadFile(
        fileUrl,
        filePath,
        callback: callback,
        onProgress: onProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError ?? true,
        lengthHeader: lengthHeader ?? Headers.contentLengthHeader,
        data: data,
        options: options,
      );

  static Future<String?> getFileSize(
    BuildContext context,
    String fileUrl, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    String? fileSizeTip,
    String? fileSizeFailTip,
    String? fileSizeErrorTip,
  }) async =>
      DownloadTool().getFileSize(
        context,
        fileUrl,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        fileSizeTip: fileSizeTip,
        fileSizeErrorTip: fileSizeErrorTip,
        fileSizeFailTip: fileSizeFailTip,
      );

  static Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case 'x5Status':
        _initController.add(X5StatusExtension.getType(call.arguments as int));
        break;
      default:
        break;
    }
  }
}
