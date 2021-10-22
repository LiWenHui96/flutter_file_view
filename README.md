# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: [中文](README-ZH.md) | English

At present, the plugin is only used by `Android`, `iOS`

You can use [FileLocalViewer](lib/src/view/file_local_viewer.dart) to preview local files

You can use [FileNetworkViewer](lib/src/view/file_network_viewer.dart) to download the network link
and preview the file in combination with `FileLocalView`

### Use of third-party plugins

- Use `dio` to make network requests.
- The v1.0.0 version no longer provides permission requests.
- It is recommended to use `getTemporaryDirectory()` as the target path, which can be implemented
  using the [path_provider](https://pub.dev/packages/path_provider) plugin.

## Preparing for use

### Version constraints

```yaml
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=2.5.0"
```

### Flutter

Add `flutter_file_view` to `pubspec.yaml` dependencies.

```yaml
dependencies:
  flutter_file_view: ^latest_version
```

### iOS

Make sure you add the following key to `Info.plist` for iOS

```
<key>io.flutter.embedded_views_preview</key><true/>
```

### Android

Android P Unable to download kernel Solution

Add a piece of code in label `application` on `AndroidManifst.xml` file

```
android:networkSecurityConfig="@xml/network_security_config"
```

Add a file named `network_security_config.xml` in `res/xml` directory, The content of the file is

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

## Local File Preview

#### Android is implemented by [Tencent X5](https://x5.tencent.com/docs/index.html), iOS is implemented by [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).

### Supported file type

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt,jpg,jpeg,png`

### Usage

| Name                      | Old Name                  | Type           | Description                                                    | Default                                                        |
| ------------------------- | ------------------------- | -------------- | -------------------------------------------------------------- | -------------------------------------------------------------- |
| localFilePath             | filePath                  | `String`       | Local file path (full path)                                    | Required                                                       |
| unsupportedPlatformTip    | unSupportPlatformTip      | `String`       | Platform hints are not supported                               | `当前仅支持Android、iOS平台`                                     |
| nonexistentFileTip        | nonExistentFileTip        | `String`       | Prompt that the file under this file path does not exist       | `文件不存在`                                                    |
| openFailTip               | fileFailTip               | `String`       | Prompt of failure to open file                                 | `文件打开失败`                                                   |
| loadingWidget             | -                         | `Widget`       | Widget showing loading status                                  | See source file                                                |
| unsupportedTypeWidget     | unSupportFileWidget       | `Widget`       | Unsupported file type widget                                   | See source file                                                |

### Android special notes

- The X5 kernel loading method has been integrated in the plugin.
- Get the current kernel loading status through `getX5Status()`.
- It can be initialized by itself through `initX5()` . It is mainly used to solve the problem of
  unsuccessful download.
- Through the following scheme, kernel load listening can be realized after `initX5()` call.

```
FlutterFileView.initController.listen((res) {
  EX5Status ex5status = res;
  print(ex5status);
});
```

### READ

- Not Support Google Play, Reason: [Issues 1.11](https://x5.tencent.com/docs/questions.html).
- Running on Android emulator is not supported.

## Network Link View

A **network link view** which based on the WeChat’s UI, with download function and view click
effect.

### Usage

| Name                      | Type                    | Description                                                          | Default                          |
| ------------------------- | ----------------------- | -------------------------------------------------------------------- | -------------------------------- |
| downloadUrl               | `String`                | Download link for file                                               | Required                         |
| downloadPath              | `String`                | Storage address of the file                                          | Required                         |
| onViewPressed             | `VoidCallback`          | File viewing function                                                | Required                         |
| fileShowName              | `String`                | Deprecated                                                           | -                                |
| fileType                  | `String`                | Deprecated                                                           | -                                |
| fileNameStyle             | `TextStyle`             | The style of the displayed file name                                 | See source file                  |
| fileSizeStyle             | `TextStyle`             | The style of the text showing the size of the file resource          | See source file                  |
| downloadTitle             | `Widget`                | Button title when downloadable                                       | 文件下载                          |
| viewTitle                 | `String`                | Button title when viewable                                           | 文件查看                          |
| btnTitleColor             | `Color`                 | Button title color                                                   | `Colors.white`                   |
| btnBgColor                | `Color`                 | Button background color                                              | `Theme.of(context).primaryColor` |
| borderSide                | `BorderSide`            | Button border                                                        | `ElevatedButton` 默认             |

## Future Plans

- Realize online viewing of network links. At present, `FileNetworkViewer` can be used to view after
  downloading.
- Consider removing the `onViewPressed` function of `FileNetworkViewer` and providing additional
  events for opening files that cannot be previewed.

## Other Api

- Convert file size through `fileSize()`.
- Download network files through `downloadFileByNet()`.
- Get the network file size through `getFileSizeByNet()`.
