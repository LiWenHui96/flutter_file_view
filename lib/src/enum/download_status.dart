/// @Describe: The download status of file.
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/25

enum DownloadStatus {
  /// Not downloaded
  none,

  /// Downloading
  downloading,

  /// Download complete
  done,

  /// Download fail
  fail,

  /// Download exception
  error
}
