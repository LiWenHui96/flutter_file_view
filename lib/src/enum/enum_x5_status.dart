///
/// @Describe: Tencent X5 State
///            Tencent X5 加载状态
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/10
///

enum EX5Status {
  ///
  /// Not initialized
  ///
  /// 尚未初始化
  ///
  init,

  ///
  /// Initializing
  ///
  /// 正在初始化
  ///
  initializing,

  ///
  /// Initialization succeeded
  ///
  /// 初始化成功
  ///
  success,

  ///
  /// Initialization failed
  ///
  /// 初始化失败
  ///
  fail,

  ///
  /// Download succeeded
  ///
  /// 下载成功
  ///
  downloadSucceeded,

  ///
  /// Download failed
  ///
  /// 下载失败
  ///
  downloadFailed,

  ///
  /// Downloading
  /// 正在下载
  ///
  downloading,

  ///
  /// Installation succeeded
  ///
  /// 安装成功
  ///
  installationSucceeded,

  ///
  /// Installation failed
  ///
  /// 安装失败
  ///
  installationFailed,
}

extension EX5StatusExtension on EX5Status {
  static EX5Status getTypeValue(int i) {
    switch (i) {
      case 0:
        return EX5Status.init;
      case 1:
        return EX5Status.initializing;
      case 10:
        return EX5Status.success;
      case 11:
        return EX5Status.fail;
      case 20:
        return EX5Status.downloadSucceeded;
      case 21:
        return EX5Status.downloadFailed;
      case 22:
        return EX5Status.downloading;
      case 30:
        return EX5Status.installationSucceeded;
      case 31:
        return EX5Status.installationFailed;
      default:

        ///
        /// It returns to [EX5Status.init] status by default
        ///
        /// 默认情况下，它返回到 [EX5Status.init] 状态
        ///
        return EX5Status.init;
    }
  }
}
