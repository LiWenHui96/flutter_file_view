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
  INIT,

  ///
  /// Initializing
  ///
  /// 正在初始化
  ///
  INIT_LOADING,

  ///
  /// Initialization succeeded
  ///
  /// 初始化成功
  ///
  SUCCESS,

  ///
  /// Initialization failed
  ///
  /// 初始化失败
  ///
  FAIL,

  ///
  /// Download succeeded
  ///
  /// 下载成功
  ///
  DOWNLOAD_SUCCESS,

  ///
  /// Download failed
  ///
  /// 下载失败
  ///
  DOWNLOAD_FAIL,

  ///
  /// Downloading
  /// 正在下载
  ///
  DOWNLOAD_LOADING,

  ///
  /// Installation succeeded
  ///
  /// 安装成功
  ///
  INSTALL_SUCCESS,

  ///
  /// Installation failed
  ///
  /// 安装失败
  ///
  INSTALL_FAIL,
}

extension EX5StatusExtension on EX5Status {
  static EX5Status getTypeValue(int i) {
    switch (i) {
      case 0:
        return EX5Status.INIT;
      case 1:
        return EX5Status.INIT_LOADING;
      case 10:
        return EX5Status.SUCCESS;
      case 11:
        return EX5Status.FAIL;
      case 20:
        return EX5Status.DOWNLOAD_SUCCESS;
      case 21:
        return EX5Status.DOWNLOAD_FAIL;
      case 22:
        return EX5Status.DOWNLOAD_LOADING;
      case 30:
        return EX5Status.INSTALL_SUCCESS;
      case 31:
        return EX5Status.INSTALL_FAIL;
      default:

        ///
        /// It returns to [EX5Status.INIT] status by default
        ///
        /// 默认情况下，它返回到 [EX5Status.INIT] 状态
        ///
        return EX5Status.INIT;
    }
  }
}
