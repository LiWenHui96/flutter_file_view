/// @Describe: The type of view
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

enum ViewType {
  /// Not initialized
  none,

  /// Unsupported platform
  unsupported_platform,

  /// Nonexistent file
  non_existent,

  /// Unsupported file type
  unsupported_type,

  /// X5 Initialization failed
  engine_fail,

  /// Successfully opened file
  done
}
