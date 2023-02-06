/// @Describe: The state of X5 kernel.
///
/// @Author: LiWeNHuI
/// @Date: 2022/9/11

enum X5Status {
  /// Not initialized
  NONE,

  /// Ready to start initializing
  START,

  /// Initialization complete
  DONE,

  /// Initialization exception
  ERROR,

  /// Download successful
  DOWNLOAD_SUCCESS,

  /// Download failed
  DOWNLOAD_FAIL,

  /// Downloading
  DOWNLOADING,

  /// Non-required downloads
  DOWNLOAD_NON_REQUIRED,

  /// Non-Wi-Fi
  DOWNLOAD_CANCEL_NOT_WIFI,

  /// The number of downloads initiated more than 1 time
  DOWNLOAD_OUT_OF_ONE,

  /// During the download request, the download is not repeated and the
  /// download is canceled
  DOWNLOAD_CANCEL_REQUESTING,

  /// No download request is initiated
  DOWNLOAD_NO_NEED_REQUEST,

  /// The bandwidth is not allowed, the download is cancelled
  DOWNLOAD_FLOW_CANCEL,

  /// Installation succeeded
  INSTALL_SUCCESS,

  /// Installation failed
  INSTALL_FAIL
}

/// Extension class for [X5Status].
extension X5StatusExtension on X5Status {
  /// get enumeration value
  static X5Status getType(int? i) {
    switch (i) {
      case 1:
        return X5Status.START;
      case 10:
        return X5Status.DONE;
      case 11:
        return X5Status.ERROR;
      case 20:
        return X5Status.DOWNLOAD_SUCCESS;
      case 21:
        return X5Status.DOWNLOAD_FAIL;
      case 22:
        return X5Status.DOWNLOADING;
      case 23:
        return X5Status.DOWNLOAD_NON_REQUIRED;
      case 24:
        return X5Status.DOWNLOAD_CANCEL_NOT_WIFI;
      case 25:
        return X5Status.DOWNLOAD_OUT_OF_ONE;
      case 26:
        return X5Status.DOWNLOAD_CANCEL_REQUESTING;
      case 27:
        return X5Status.DOWNLOAD_NO_NEED_REQUEST;
      case 28:
        return X5Status.DOWNLOAD_FLOW_CANCEL;
      case 30:
        return X5Status.INSTALL_SUCCESS;
      case 31:
        return X5Status.INSTALL_FAIL;
      default:
        return X5Status.NONE;
    }
  }
}
