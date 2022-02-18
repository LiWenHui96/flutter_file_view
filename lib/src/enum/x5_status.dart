/// @Describe: Loading state of the X5 kernel
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

enum X5Status {
  /// Not initialized
  none,

  /// Ready to start initializing
  start,

  /// Initialization complete
  done,

  /// Initialization exception
  error,

  /// Download successful
  download_success,

  /// Download failed
  download_fail,

  /// Downloading
  downloading,

  /// Installation succeeded
  install_success,

  /// Installation failed
  install_fail
}

extension X5StatusExtension on X5Status {
  static X5Status getType(int i) {
    switch (i) {
      case 0:
        return X5Status.none;
      case 1:
        return X5Status.start;
      case 10:
        return X5Status.done;
      case 11:
        return X5Status.error;
      case 20:
        return X5Status.download_success;
      case 21:
        return X5Status.download_fail;
      case 22:
        return X5Status.downloading;
      case 30:
        return X5Status.install_success;
      case 31:
        return X5Status.install_fail;
      default:
        return X5Status.none;
    }
  }
}
