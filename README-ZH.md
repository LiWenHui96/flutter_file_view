# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: 中文 | [English](README.md)

目前该插件仅限于 `Android` ，`iOS` 使用

可使用 [FileLocalViewer](lib/src/view/file_local_viewer.dart) 实现本地文件预览

可使用 [FileNetworkViewer](lib/src/view/file_network_viewer.dart) 实现网络链接下载，结合 `FileLocalViewer` 实现预览

### 第三方插件使用

- 使用 `dio` 进行网络请求
- v1.0.0版本已不再提供权限请求
- 推荐使用 `getTemporaryDirectory()`
  作为目标路径（使用[path_provider](https://pub.dev/packages/path_provider)插件可实现）

## 准备工作

### 版本限制

```yaml
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=2.5.0"
```

### Flutter

将 `flutter_file_view` 添加至 `pubspec.yaml` 引用。

```yaml
dependencies:
  flutter_file_view: ^latest_version
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

## 本地文件预览

#### Android 由 [Tencent X5](https://x5.tencent.com/docs/index.html) 实现，iOS 由 [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) 实现

### 所支持的文件类型

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt,jpg,jpeg,png`

### 使用方法

| 参数名                     | 旧参数名                   | 类型                    | 描述                                      | 默认值                           |
| ------------------------- | ------------------------- | ----------------------- | ---------------------------------------- | -------------------------------- |
| localFilePath             | filePath                  | `String`                | 本地文件路径（全量路径）                    | 必填项                           |
| unsupportedPlatformTip    | unSupportPlatformTip      | `String`                | 不支持平台的提示                           | `当前仅支持Android、iOS平台`      |
| nonexistentFileTip        | nonExistentFileTip        | `String`                | 此文件路径下的文件不存在的提示               | `文件不存在`                      |
| openFailTip               | fileFailTip               | `String`                | 打开文件失败的提示                         | `文件打开失败`                    |
| loadingWidget             | -                         | `Widget`                | 加载状态的部件                             | 见源文件                         |
| unsupportedTypeWidget     | unSupportFileWidget       | `Widget`                | 不支持的文件类型的部件                      | 见源文件                         |

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

## 网络链接视图

基于微信 UI 的 **网络链接视图**，带有下载功能以及查看的点击效果

### 使用方法

| 参数名                     | 类型                    | 描述                                      | 默认值                           |
| ------------------------- | ----------------------- | ---------------------------------------- | -------------------------------- |
| downloadUrl               | `String`                | 下载文件链接                               | 必填项                           |
| downloadPath              | `String`                | 下载文件存储地址                           | 必填项                           |
| onViewPressed             | `VoidCallback`          | 文件查看功能                               | 必填项                           |
| fileShowName              | `String`                | 已弃用                                    | -                               |
| fileType                  | `String`                | 已弃用                                    | -                               |
| fileNameStyle             | `TextStyle`             | 所展示文件名称的风格                       | 见源文件                          |
| fileSizeStyle             | `TextStyle`             | 所展示文件资源大小的文字的风格              | 见源文件                          |
| downloadTitle             | `Widget`                | 可下载时的按钮标题                         | 文件下载                          |
| viewTitle                 | `String`                | 可查看时的按钮标题                         | 文件查看                          |
| btnTitleColor             | `Color`                 | 按钮标题颜色                              | `Colors.white`                   |
| btnBgColor                | `Color`                 | 按钮背景颜色                               | `Theme.of(context).primaryColor`|
| borderSide                | `BorderSide`            | 按钮边框                                  | `ElevatedButton` 默认            |

## 未来计划

- 实现网络链接的在线查看，当前可使用 `FileNetworkViewer` 实现下载后查看
- 考虑将去除 `FileNetworkViewer` 的 `onViewPressed` 功能，将额外提供事件用于打开无法预览的文件

## 其他Api

- `fileSize()` 用于换算文件大小
- `downloadFileByNet()` 用于下载网络文件
- `getFileSizeByNet()` 用于获取网络文件大小
