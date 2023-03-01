## 2.2.1

* TBS(44275) is the last version that supports `TbsReaderView`!

## 2.2.0+1

* Add `buttonTextStyle`.

## 2.2.0

* Add `OnCustomViewStatusBuilder`, `OnCustomX5StatusBuilder`.
* Update TBS.

## 2.1.3

* Update TBS.

## 2.1.3-alpha.1

* Add `android.permission.WRITE_SETTINGS`.
* Delete `android.permission.ACCESS_WIFI_STATE`, `android.permission.WRITE_EXTERNAL_STORAGE`.

## 2.1.2

* Fix [#15](https://github.com/LiWenHui96/flutter_file_view/issues/15). Resolve an issue with using `FileViewController.file()`.
* Add `customFileName`, define the name of the stored file yourself.

## 2.1.1

* Upgrade the version of TBS, the current version is 44199.
* Update README.md.

## 2.1.0

* Add the loading progress of iOS.

## 2.1.0-alpha.1

* We've ushered in major changes, not just method changes, but more performance improvements.

### Breaking changes

* Use [FileView](lib/src/file_view.dart) instead of `LocalFileViewer`.
* Make `NetworkFileViewer` a obsolete product.
* For details on how to use it, see [README.md](README.md).

## 2.0.8+6

* Number of retries to remove X5 installations.

## 2.0.8+5

* Rollback TBS version to 44085.

## 2.0.8+4

* Fix [#10](https://github.com/LiWenHui96/flutter_file_view/issues/10).

## 2.0.8+3

* Fix known issues.

## 2.0.8+2

* Fix known issues.

## 2.0.8+1

* Fixed the issue that the plugin could not be loaded when it was first opened.

## 2.0.8

* On the Android platform, it supports opening two TbsReaderViews, but it is still not supported to display multiple TbsReaderViews under the same widget;

## 2.0.7

* On Android, software startup initialization is no longer provided.

## 2.0.6

* Fix `In android always says : Engine initilializing ,please wait` [#5](https://github.com/LiWenHui96/flutter_file_view/issues/5)

## 2.0.5

* Update LICENSE.

## 2.0.4

* Update README.md

## 2.0.3

* Fixed bug using titleMedium and bodyMedium fields that didn't exist in TextTheme before Flutter 2.10.x ([#3](https://github.com/LiWenHui96/flutter_file_view/issues/3))

## 2.0.2

* Update CHANGELOG.md

## 2.0.1

* Add the processing of the engine loading status and failure in Android.

## 2.0.0

* Welcome to a brand new version.
* `FileLocalViewer` changed to `LocalFileViewer`.
* `FileNetworkViewer` changed to `NetworkFileViewer`.
* For details on how to use it, see [README.md](README.md)

## 1.3.0

* Android programming language is adjusted from Java to kotlin.
* Optimize with flutter_lints.

## 1.2.1

* Update tool class name

## 1.2.0

* The code has changed greatly and the function has been optimized. Please pay attention to the
  following.
* `FileLocalView` changed to `FileLocalViewer`.
* `FileNetworkView` changed to `FileNetworkViewer`.

## 1.1.3

* Add API description in README.md.
* Change API name.
* Optimize `fileSize()` function.

## 1.1.2

* iOS minimum version changed to 9.0.

## 1.1.1

* Update README.md.

## 1.1.0

* Add X5 kernel initialization listening.
* Update README.md.

## 1.0.2

* Update README.md.

## 1.0.1

* `FileNetworkView` no longer provides `Scaffold()` and needs to implement the page itself.

## 1.0.0

* Adds the number of retries to optimize kernel loading.
* Modify the `initX5()` method to no longer provide the return value.
* No longer provide permission request.

## 0.1.4

* Update minimum Flutter SDK to 2.5.

## 0.1.3

* Specify Java 8 for Android build.

## 0.1.2

* Add description.

## 0.1.1

* Update README.md.

## 0.1.0

* Release.

## 0.0.4

* Add file download function.
* Add a network link view with file download and file view.

## 0.0.3

* Add example.
* New adaptation `xls, xlsx` scheme of iOS.
* Add Tencent X5 Kernel load state constant value.
* Add Permission for Android.

## 0.0.2

* Function realization.

## 0.0.1

* Project initialization.
