import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'flutter_file_view.dart';

/// @Describe: Tools
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/22

class FileViewTools {
  /// 获取文件的存储地址。
  ///
  /// Get the storage address of the file.
  static Future<String> getDirectoryPath() async {
    final String directoryPath =
        '${(await FlutterFileView.getTemporaryDirectory()).path}/$cacheKey/';

    /// 检验文件夹是否存在，若不存在则进行创建操作。
    ///
    /// Check to see if the folder exists, and create it if it doesn't.
    await Directory(directoryPath).create(recursive: true);

    return directoryPath;
  }

  /// 获取文件存储的标识。
  ///
  /// Get the key for file storage.
  static String getFileSaveKey(String filePath, {String? fileName}) {
    return '${fileName ?? base64.encode(utf8.encode(getFileName(filePath)))}'
        '.'
        '${getFileType(filePath)}';
  }

  /// 获取文件的名称。
  ///
  /// Get the name of the file.
  static String getFileName(String filePath) {
    if (filePath.isEmpty) {
      return '';
    }

    final int i = filePath.lastIndexOf('/');
    return i <= -1 ? '' : filePath.substring(i + 1);
  }

  /// 获取文件的后缀名称。
  ///
  /// Get the type of the file.
  static String getFileType(String filePath) {
    if (filePath.isEmpty) {
      return '';
    }

    final int i = filePath.lastIndexOf('.');
    return i <= -1 ? '' : filePath.substring(i + 1);
  }

  /// Whether there is a file with this path.
  static bool fileExists(String filePath) => File(filePath).existsSync();

  /// 通过文件路径验证是否为可支持的。
  ///
  /// Verify that it is supported by file path.
  static bool isSupportByPath(String filePath) =>
      isSupportByType(getFileType(filePath));

  /// 通过文件类型验证是否为可支持的。
  ///
  /// Verify that it is supported by file type.
  static bool isSupportByType(String fileType) {
    final RegExp regExp = RegExp(r'(doc(?:|x)|xls(?:|x)|ppt(?:|x)|pdf|txt)$');
    return regExp.hasMatch(fileType.toLowerCase());
  }

  /// 下载文件
  ///
  /// Download files.
  static Future<bool> downloadFile(
    String fileUrl,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    NetworkConfig? config,
  }) async {
    /// 当文件存在时，不再进行下载操作。
    ///
    /// When the file exists, no more download operations are performed.
    if (fileExists(savePath)) {
      return true;
    }

    try {
      final Dio dio = Dio(
        BaseOptions(connectTimeout: 90 * 1000, receiveTimeout: 90 * 1000),
      );

      final Response<dynamic> response = await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: config?.queryParameters,
        cancelToken: config?.cancelToken,
        deleteOnError: config?.deleteOnError ?? true,
        lengthHeader: config?.lengthHeader ?? Headers.contentLengthHeader,
        data: config?.data,
        options: config?.options,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
