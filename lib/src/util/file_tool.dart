import 'dart:io';

/// @Describe: File tool
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class FileTool {
  /// Whether the file exists
  static bool isExistsFile(String filePath) => File(filePath).existsSync();

  /// Whether type of the file support
  static bool isSupportOpen(String fileType) {
    final List<String> types = <String>[
      'docx',
      'doc',
      'xlsx',
      'xls',
      'pptx',
      'ppt',
      'pdf',
      'txt'
    ];
    return types.contains(fileType.toLowerCase());
  }

  /// Name of the file
  static String getFileName(String filePath) {
    if (filePath.isEmpty) {
      return '';
    }

    final int i = filePath.lastIndexOf('/');
    return i <= -1 ? '' : filePath.substring(i + 1);
  }

  /// Type of the file
  static String getFileType(String filePath) {
    if (filePath.isEmpty) {
      return '';
    }

    final int i = filePath.lastIndexOf('.');
    return i <= -1 ? '' : filePath.substring(i + 1);
  }
}

/// Obtain the corresponding display information through file size conversion
String fileSize(dynamic fileSize, [int round = 3]) {
  const int bDivider = 1024;
  int size;
  try {
    size = int.parse(fileSize.toString());
  } catch (e) {
    throw ArgumentError('Can not parse the size parameter: $e');
  }

  final int uRound = size % bDivider == 0 ? 0 : round;

  if (size < bDivider) {
    return '$size B';
  }

  const int kbDivider = bDivider * bDivider;
  if (size < kbDivider) {
    return '${(size / bDivider).toStringAsFixed(uRound)} KB';
  }

  const int mbDivider = kbDivider * bDivider;
  if (size < mbDivider) {
    return '${(size / kbDivider).toStringAsFixed(uRound)} MB';
  }

  const int gbDivider = mbDivider * bDivider;
  if (size < gbDivider) {
    return '${(size / mbDivider).toStringAsFixed(uRound)} GB';
  }

  const int tbDivider = gbDivider * bDivider;
  if (size < tbDivider) {
    return '${(size / gbDivider).toStringAsFixed(uRound)} TB';
  }

  const int pbDivider = tbDivider * bDivider;
  if (size < pbDivider) {
    return '${(size / tbDivider).toStringAsFixed(uRound)} PB';
  }

  return '${(size / tbDivider).toStringAsFixed(round)} PB';
}
