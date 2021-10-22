import 'dart:io';

///
/// @Describe: File tool
///            文件工具类
///
/// @Author: LiWeNHuI
/// @Date: 2021/10/20
///

class FileTool {
  ///
  /// Whether the file exists
  ///
  /// 文件是否存在
  ///
  static Future<bool> isExistsFile(String filePath) async {
    return await File(filePath).exists();
  }

  ///
  /// Name of the file
  ///
  /// 文件名称
  ///
  static String getFileName(String filePath) {
    String path = filePath;

    if (path.isEmpty) {
      return '';
    }

    int i = path.lastIndexOf('/');
    if (i <= -1) {
      return '';
    }
    return path.substring(i + 1);
  }

  ///
  /// Type of file
  ///
  /// 文件类型
  ///
  static String getFileType(String filePath) {
    String path = filePath;

    if (path.isEmpty) {
      return '';
    }

    int i = path.lastIndexOf('.');
    if (i <= -1) {
      return '';
    }

    return path.substring(i + 1);
  }
}

///
/// Obtain the corresponding display information through file size conversion
///
/// 文件大小换算为相应的展示信息
///
String fileSize(dynamic fileSize, [int round = 3]) {
  var bDivider = 1024;
  int size;
  try {
    size = int.parse(fileSize.toString());
  } catch (e) {
    throw ArgumentError('Can not parse the size parameter: $e');
  }

  var uRound = size % bDivider == 0 ? 0 : round;

  if (size < bDivider) {
    return '$size B';
  }

  var kbDivider = bDivider * bDivider;
  if (size < kbDivider) {
    return '${(size / bDivider).toStringAsFixed(uRound)} KB';
  }

  var mbDivider = kbDivider * bDivider;
  if (size < mbDivider) {
    return '${(size / kbDivider).toStringAsFixed(uRound)} MB';
  }

  var gbDivider = mbDivider * bDivider;
  if (size < gbDivider) {
    return '${(size / mbDivider).toStringAsFixed(uRound)} GB';
  }

  var tbDivider = gbDivider * bDivider;
  if (size < tbDivider) {
    return '${(size / gbDivider).toStringAsFixed(uRound)} TB';
  }

  var pbDivider = tbDivider * bDivider;
  if (size < pbDivider) {
    return '${(size / tbDivider).toStringAsFixed(uRound)} PB';
  }

  return '${(size / tbDivider).toStringAsFixed(round)} PB';
}
