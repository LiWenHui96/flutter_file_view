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
  LOADING,

  ///
  /// Nonexistent file
  ///
  /// 文件不存在
  ///
  NONEXISTENT,

  ///
  /// Unsupported file type
  ///
  /// 文件类型不支持
  ///
  UNSUPPORTED_TYPE,

  ///
  /// only Android
  ///
  /// Initialization failed Tencent X5
  ///
  /// Tencent X5 加载失败
  ///
  ENGINE_FAIL,

  ///
  /// only Android, iOS
  ///
  /// Unsupported platform
  ///
  /// 平台不支持
  ///
  UNSUPPORTED_PLATFORM,

  ///
  /// fail
  ///
  /// 失败
  ///
  FAIL,

  ///
  /// success
  ///
  /// 成功
  ///
  SUCCESS,
}
