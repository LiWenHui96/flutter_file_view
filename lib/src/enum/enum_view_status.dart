///
/// @Describe: View state
///            文件状态
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/10
///

enum EViewStatus {
  ///
  /// File initialization / loading status
  ///
  /// 文件初始化/加载状态
  ///
  loading,

  ///
  /// Nonexistent file
  ///
  /// 文件不存在
  ///
  nonexistent,

  ///
  /// Unsupported file type
  ///
  /// 文件类型不支持
  ///
  unsupporeedType,

  ///
  /// only Android
  ///
  /// Initialization failed Tencent X5
  ///
  /// Tencent X5 加载失败
  ///
  engineFail,

  ///
  /// only Android, iOS
  ///
  /// Unsupported platform
  ///
  /// 平台不支持
  ///
  unsupporeedPlatform,

  ///
  /// fail
  ///
  /// 失败
  ///
  fail,

  ///
  /// success
  ///
  /// 成功
  ///
  success,
}
