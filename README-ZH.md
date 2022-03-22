# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: 中文 | [English](README.md)

> 目前该插件仅限于 Android，iOS 使用

* 可使用 [LocalFileViewer](lib/src/view/local_file_viewer.dart) 实现本地文件预览。
* 可使用 [NetworkFileViewer](lib/src/view/network_file_viewer.dart) 实现网络链接下载，结合 `LocalFileViewer` 实现预览。

### 第三方使用

* 使用 `dio` 进行网络请求。
* 推荐使用 `getTemporaryDirectory()` 作为目标路径（使用[path_provider](https://pub.dev/packages/path_provider)插件可实现）。

## 准备工作

### 版本限制

```yaml
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=2.5.0"
```

### 添加依赖

1. 将 `flutter_file_view` 添加至 `pubspec.yaml` 引用

```yaml
dependencies:
  flutter_file_view: ^latest_version
```

2. 执行flutter命令获取包

```
flutter pub get
```

3. 引入

```dart
import 'package:flutter_file_view/flutter_file_view.dart';
```

### 本地化配置

在 `MaterialApp` 添加

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ...
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        ...
        ViewerLocalizationsDelegate.delegate,
      ],
      ...
    );
  }
}
```

### iOS

请确保将以下键添加到 `Info.plist`

```
<key>io.flutter.embedded_views_preview</key><true/>
```

### Android

Android P 无法下载内核解决方案

在文件 `AndroidManifst.xml` 的标签 `application` 中添加代码

```
android:networkSecurityConfig="@xml/network_security_config"
android:usesCleartextTraffic="true"
```

在 `res/xml` 目录中添加一个名为 `network_security_config.xml` 的文件, 文件内容为

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

## 本地文件预览 - LocalFileViewer

> Android 由 [Tencent X5](https://x5.tencent.com/docs/index.html) 实现

> iOS 由 [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) 实现

### 所支持的文件类型

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`

### 使用方法

| 参数名 | 类型 | 描述 | 默认值 |
| --- | --- | --- | --- |
| filePath | `String` | 本地文件路径 | 必填项 |
| placeholder | `Widget?` | 加载状态的部件 | `CupertinoActivityIndicator(radius: 14.0)` |
| unsupportedPlatformWidget | `Widget?` | 在不支持的平台上显示的部件 | `Center(child: Text(ViewerLocalizations.of(context).unsupportedPlatformTip))` |
| nonExistentWidget | `Widget?` | 当文件不存在时显示的部件 | `Center(child: Text(ViewerLocalizations.of(context).nonExistentTip))` |
| unsupportedTypeWidget | `Widget` | 当文件为不支持的类型时显示的部件 | `Center(child: Text(ViewerLocalizations.of(context).unsupportedType))` |
| isBarShow | `bool` | `TbsReaderView.openFile` 所携带参数 `is_bar_show` | `false` |
| intoDownloading | `bool` | `TbsReaderView.openFile` 所携带参数 `into_downloading` | `false` |
| isBarAnimating | `bool` | `TbsReaderView.openFile` 所携带参数 `is_bar_animating` | `false` |

### Android特殊说明

- 在插件内已集成加载X5内核方法
- 通过 `getX5Status()` 可获取当前内核加载状态
- 通过 `initX5()` ，可自行初始化，主要用于解决下载不成功的问题
- 通过下述方案可在 `initX5()` 调用后实现内核加载监听

```
FlutterFileView.initController.listen((res) {
  EX5Status ex5status = res;
  print(ex5status);
});
```

### 注意事项

- 不支持Google Play，原因：[问题 1.11](https://x5.tencent.com/docs/questions.html)
- 不支持在Android 模拟器

## 网络链接视图 - NetworkFileViewer

基于微信 UI 的 **网络链接视图**，带有下载功能以及查看的点击效果

### 使用方法

| 参数名 | 类型 | 描述 | 默认值 |
| --- | --- | --- | --- |
| downloadUrl | `String` | 下载文件链接 | 必填项 |
| downloadPath | `String` | 下载文件存储地址 | 必填项 |
| onViewPressed | `VoidCallback` | 文件查看功能 | 必填项 |
| placeholder | `Widget?` | 加载状态的部件 | `CupertinoActivityIndicator(radius: 14.0)` |
| fileSizeData | `dynamic` | `FlutterFileView.getFileSize` 参数 `data` | `null` |
| fileSizeQueryParameters | `Map<String, dynamic>?` | `FlutterFileView.getFileSize` 参数 `queryParameters` | `null` |
| fileSizeOptions | `Options?` | `FlutterFileView.getFileSize` 参数 `options` | `null` |
| fileSizeTip | `String?` | `FlutterFileView.getFileSize` 参数 `fileSizeTip` | `ViewerLocalizations.of(context).fileSizeTip` |
| fileSizeFailTip | `String?` | `FlutterFileView.getFileSize` 参数 `fileSizeFailTip` | `ViewerLocalizations.of(context).fileSizeFailTip` |
| fileSizeErrorTip | `String?` | `FlutterFileView.getFileSize` 参数 `fileSizeErrorTip` | `ViewerLocalizations.of(context).fileSizeErrorTip` |
| downloadQueryParameters | `Map<String, dynamic>?` | `FlutterFileView.downloadFile` 参数 `queryParameters` | `null` |
| downloadDeleteOnError | `bool?` | `FlutterFileView.downloadFile` 参数 `deleteOnError` | `true` |
| downloadLengthHeader | `String?` | `FlutterFileView.downloadFile` 参数 `lengthHeader` | `Headers.contentLengthHeader` |
| downloadData | `dynamic` | `FlutterFileView.downloadFile` 参数 `data` | `null` |
| downloadOptions | `Options?` | `FlutterFileView.downloadFile` 参数 `options` | `null` |
| fileNameStyle | `TextStyle?` | 文件名称的样式 | `Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight:FontWeight.bold)` |
| fileSizeStyle | `TextStyle?` | 文件资源大小的文字的样式 | `Theme.of(context).textTheme.bodyText2` |
| downloadTitle | `String?` | 可下载时的按钮标题 | `ViewerLocalizations.of(context).downloadTitle` |
| viewTitle | `String?` | 可查看时的按钮标题 | `ViewerLocalizations.of(context).viewTitle` |
| buttonStyle | `ButtonStyle?` | 按钮样式 | 见源文件 |
| btnTitleColor | `Color？` | 按钮文字颜色 | `Colors.white`|
| btnBgColor | `Color？` | 按钮背景颜色 | `Theme.of(context).primaryColor` |
| progressSize | `double?` | `CircularProgressIndicator` 尺寸 | `60.0` |
| progressStrokeWidth | `double?` | `CircularProgressIndicator` 的 `strokeWidth` | `6.0` |
| progressBackgroundColor | `Color？` | `CircularProgressIndicator` 背景色 | `Theme.of(context).primaryColor`|
| progressValueColor | `Color？` | `CircularProgressIndicator` 当前值颜色 | `Colors.tealAccent` |

## 未来计划

- 实现网络链接的在线查看，当前可使用 `NetworkFileViewer` 实现下载后查看
- 考虑将去除 `NetworkFileViewer` 的 `onViewPressed` 功能，将额外提供事件用于打开无法预览的文件

## 其他Api

- `fileSize()` 用于换算文件大小
- `downloadFile()` 用于下载网络文件
- `getFileSize()` 用于获取网络文件大小
