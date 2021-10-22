import 'package:flutter/widgets.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: Download tool
///            下载工具类
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/14
///

class DownloadTool {
  static Dio _dio() {
    BaseOptions options = BaseOptions(
      connectTimeout: 90 * 1000,
      receiveTimeout: 90 * 1000,
    );
    return Dio(options);
  }

  ///
  /// Using Dio to realize file download function
  ///
  /// 利用Dio实现文件下载功能
  ///
  static Future<DownloadStatus> downloadFile(
    String fileUrl,
    String filePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      Response response = await _dio().download(
        fileUrl,
        filePath,
        onReceiveProgress: onProgress,
      );

      return response.statusCode == 200
          ? DownloadStatus.success
          : DownloadStatus.fail;
    } catch (e) {
      debugPrint('服务器出错或网络连接失败！');
      return DownloadStatus.serviceErr;
    }
  }

  ///
  /// Get file size through network link
  ///
  /// 通过网络链接获取文件大小
  ///
  static Future<String> getFileSize(String fileUrl) async {
    try {
      Response response = await _dio().head(fileUrl);

      int size = 0;
      response.headers.forEach((label, value) {
        if (label == 'content-length') {
          for (var v in value) {
            size += int.tryParse(v) ?? 0;
          }
        }
      });

      if (response.headers.toString().contains('content-length')) {
        return '文件大小：${fileSize(size)}';
      } else {
        return '文件大小获取失败';
      }
    } catch (e) {
      return '文件大小获取失败';
    }
  }
}
