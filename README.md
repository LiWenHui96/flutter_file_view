# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: [中文](README-ZH.md) | English

> At present, the plugin is only used by Android, iOS

* You can use [LocalFileViewer](lib/src/view/local_file_viewer.dart) to preview local files.
* You can use [NetworkFileViewer](lib/src/view/network_file_viewer.dart) to download the network link and preview the file in combination with `LocalFileViewer`.

### Use of third-party plugins

* Use `dio` to make network requests.
* It is recommended to use `getTemporaryDirectory()` as the target path, which can be implemented using the [path_provider](https://pub.dev/packages/path_provider) plugin.

## Preparing for use

### Version constraints

```yaml
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=2.5.0"
```

### Rely

1. Add `flutter_file_view` to `pubspec.yaml` dependencies.

```yaml
dependencies:
  flutter_file_view: ^latest_version
```

2. Get the package by executing the flutter command.

```
flutter pub get
```

3. Introduce

```dart
import 'package:flutter_file_view/flutter_file_view.dart';
```

### Localized configuration

Add in `MaterialApp`.

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

## Local File Preview - LocalFileViewer

* Android is implemented by [Tencent X5](https://x5.tencent.com/docs/index.html)
* iOS is implemented by [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)

### Supported file type

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`

### Usage

| Name | Type | Description | Default |
| --- | --- | --- | --- |
| filePath | `String` | Path to local file | Required |
| placeholder | `Widget?` | Widget displayed while the target [filePath] is loading. | `CupertinoActivityIndicator(radius: 14.0)` |
| unsupportedPlatformWidget | `Widget?` | Widget displayed on unsupported platforms | `Center(child: Text(ViewerLocalizations.of(context).unsupportedPlatformTip))` |
| nonExistentWidget | `Widget?` | Widget displayed while the file with path [filePath] does not exist | `Center(child: Text(ViewerLocalizations.of(context).nonExistentTip))` |
| unsupportedTypeWidget | `Widget` | Widget displayed while the file is of an unsupported file types | `Center(child: Text(ViewerLocalizations.of(context).unsupportedType))` |
| isBarShow | `bool` | Parameter `is_bar_show` of `TbsReaderView.openFile` | `false` |
| intoDownloading | `bool` | Parameter `into_downloading` of `TbsReaderView.openFile` | `false` |
| isBarAnimating | `bool` | Parameter `is_bar_animating` of `TbsReaderView.openFile` | `false` |

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

## Network Link Preview - NetworkFileViewer

A **network link view** which based on the WeChat’s UI, with download function and view click effect.

### Usage

| Name | Type | Description | Default |
| --- | --- | --- | --- |
| downloadUrl | `String` | Download link for file | Required |
| downloadPath | `String` | The file storage address is used to determine whether the file can be downloaded | Required |
| onViewPressed | `VoidCallback` | File viewing function | Required |
| placeholder | `Widget?` | Widget displayed while the target [downloadUrl] is loading. | `CupertinoActivityIndicator(radius: 14.0)` |
| fileSizeData | `dynamic` | Parameter `data` of `FlutterFileView.getFileSize` | `null` |
| fileSizeQueryParameters | `Map<String, dynamic>?` | Parameter `queryParameters` of `FlutterFileView.getFileSize` | `null` |
| fileSizeOptions | `Options?` | Parameter `options` of `FlutterFileView.getFileSize` | `null` |
| fileSizeTip | `String?` | Parameter `fileSizeTip` of `FlutterFileView.getFileSize` | `ViewerLocalizations.of(context).fileSizeTip` |
| fileSizeFailTip | `String?` | Parameter `fileSizeFailTip` of `FlutterFileView.getFileSize` | `ViewerLocalizations.of(context).fileSizeFailTip` |
| fileSizeErrorTip | `String?` | Parameter `fileSizeErrorTip` of `FlutterFileView.getFileSize` | `ViewerLocalizations.of(context).fileSizeErrorTip` |
| downloadQueryParameters | `Map<String, dynamic>?` | Parameter `queryParameters` of `FlutterFileView.downloadFile` | `null` |
| downloadDeleteOnError | `bool?` | Parameter `deleteOnError` of `FlutterFileView.downloadFile` | `true` |
| downloadLengthHeader | `String?` | Parameter `lengthHeader` of `FlutterFileView.downloadFile` | `Headers.contentLengthHeader` |
| downloadData | `dynamic` | Parameter `data` of `FlutterFileView.downloadFile` | `null` |
| downloadOptions | `Options?` | Parameter `options` of `FlutterFileView.downloadFile` | `null` |
| fileNameStyle | `TextStyle?` | The style of the displayed file name | `Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight:FontWeight.bold)` |
| fileSizeStyle | `TextStyle?` | The style of the displayed file size | `Theme.of(context).textTheme.bodyText2` |
| downloadTitle | `String?` | Button title when downloadable | `ViewerLocalizations.of(context).downloadTitle` |
| viewTitle | `String?` | Button title when viewable | `ViewerLocalizations.of(context).viewTitle` |
| buttonStyle | `ButtonStyle?` | Button style | See source file |
| btnTitleColor | `Color？` | The color of the text of the button | `Colors.white`|
| btnBgColor | `Color？` | The color of the button's background | `Theme.of(context).primaryColor` |
| progressSize | `double?` | Size of `CircularProgressIndicator` | `60.0` |
| progressStrokeWidth | `double?` | `strokeWidth` of `CircularProgressIndicator` | `6.0` |
| progressBackgroundColor | `Color？` | Background color of `CircularProgressIndicator`  | `Theme.of(context).primaryColor`|
| progressValueColor | `Color？` | The value color of `CircularProgressIndicator` | `Colors.tealAccent` |

## Future Plans

- Realize online viewing of network links. At present, `NetworkFileViewer` can be used to view after downloading.
- Consider removing the `onViewPressed` function of `NetworkFileViewer` and providing additional events for opening files that cannot be previewed.

## Other Api

- Convert file size through `fileSize()`.
- Download network files through `downloadFile()`.
- Get the network file size through `getFileSize()`.

> If you like my project, please in the upper right corner of the project "Star". Your support is my biggest encouragement! ^_^