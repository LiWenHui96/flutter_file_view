import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe: Download tool
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class DownloadTool {
  static Dio _dio() {
    final BaseOptions options = BaseOptions(
      connectTimeout: 90 * 1000,
      receiveTimeout: 90 * 1000,
    );
    return Dio(options);
  }

  /// Using Dio to realize file download function
  Future<void> downloadFile(
    String fileUrl,
    String filePath, {
    required Function(DownloadStatus value) callback,
    ProgressCallback? onProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    callback(DownloadStatus.none);

    try {
      callback(DownloadStatus.downloading);

      final Response<dynamic> response = await _dio().download(
        fileUrl,
        filePath,
        onReceiveProgress: onProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

      callback(response.statusCode == 200
          ? DownloadStatus.done
          : DownloadStatus.fail);
    } catch (e) {
      callback(DownloadStatus.error);
    }
  }

  /// Get file size through network link
  Future<String?> getFileSize(
    BuildContext context,
    String fileUrl, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    String? fileSizeTip,
    String? fileSizeErrorTip,
    String? fileSizeFailTip,
  }) async {
    final ViewerLocalizations local = ViewerLocalizations.of(context);

    try {
      final Response<dynamic> response = await _dio().head<dynamic>(
        fileUrl,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );

      int size = 0;
      response.headers.forEach((String label, List<String> value) {
        if (label == 'content-length') {
          for (final String v in value) {
            size += int.tryParse(v) ?? 0;
          }
        }
      });

      if (response.headers.toString().contains('content-length')) {
        return '${fileSizeTip ?? local.fileSize}${fileSize(size)}';
      } else {
        return fileSizeFailTip ?? local.fileSizeFail;
      }
    } catch (e) {
      return fileSizeErrorTip ?? local.fileSizeError;
    }
  }
}
