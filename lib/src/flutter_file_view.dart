import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

class FlutterFileView {
  static MethodChannel _channel = MethodChannel(channelName)
    ..setMethodCallHandler(_handler);

  static StreamController<EX5Status> _initController =
      new StreamController.broadcast();

  static Stream<EX5Status> get initController => _initController.stream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///
  /// 初始化 Tencent X5
  /// 插件已实现，自动化加载，此方法仅在您所需要时使用
  ///
  /// only Android, iOS Ignore
  ///
  static Future<void> initX5() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('manualInitX5');
    }
  }

  ///
  /// 获取 X5内核 当前状态
  ///
  /// only Android, iOS Ignore
  ///
  static Future<EX5Status?> getX5Status() async {
    if (Platform.isAndroid) {
      int i = await _channel.invokeMethod('getX5Status');
      return EX5StatusExtension.getTypeValue(i);
    }

    // 其他平台 返回null
    return null;
  }

  ///
  /// 提供文件下载功能
  ///
  static Future<DownloadStatus> downloadFileByNet(
    String fileUrl,
    String filePath, {
    ProgressCallback? onProgress,
  }) async {
    return await DownloadTool.downloadFile(
      fileUrl,
      filePath,
      onProgress: onProgress,
    );
  }

  ///
  /// 获取网络资源文件大小
  ///
  static Future<String> getFileSizeByNet(String fileUrl) async {
    return await DownloadTool.getFileSize(fileUrl);
  }

  ///
  /// 监听回调方法
  ///
  static Future _handler(MethodCall call) {
    switch (call.method) {
      case 'x5Status':
        _initController.add(EX5StatusExtension.getTypeValue(call.arguments));
        break;
    }

    return Future.value();
  }
}
