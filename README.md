# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: [中文](README-ZH.md) | English

> At present, the plugin is only used by Android, iOS.
>
> Android is implemented by [Tencent X5](https://x5.tencent.com/docs/index.html).
>
> iOS is implemented by [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).

## ✅ Supported file type

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`

## ⏰ Init

```dart
FlutterFileView.init();
```

## 💼 2.0.x -> 2.1.0

### Outdated scheme.

```dart
@override
Widget build(BuildContext context) {
  return LocalFileViewer(filePath: localPath ?? '');
}
```

### Current scheme.

```dart
@override
Widget build(BuildContext context) {
  return FileView(
    controller: FileViewController.asset('assets/files/$filePath'),
  );
}
```

There are still many usages of [FileViewController](lib/src/file_view.dart) at present, such as the representation of some states and so on.

## 📲 Use of third-party plugins

* Use `dio` to make network requests.

## ⏳ Preparing for use

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

## 🤖 Android

### Android P Unable to download kernel Solution

Add a piece of code in label `application` on `AndroidManifst.xml` file

```
android:networkSecurityConfig="@xml/network_security_config"
android:usesCleartextTraffic="true"
```

Add a file named `network_security_config.xml` in `res/xml` directory, The content of the file is

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

### READ

- Subsequent TBS upgrades will not be performed. For details, see [TBS-文档接口TbsReaderView接口问题说明](https://doc.weixin.qq.com/doc/w3_AGoAtwbdAFw5hQq0KqWRPmmRF18F3?scode=AJEAIQdfAAo7OBDhdiAGoAtwbdAFw)
- Not Support Google Play, Reason: [Issues 1.11](https://x5.tencent.com/docs/questions.html).
- Running on Android emulator is not supported.

> If you like my project, please in the upper right corner of the project "Star". Your support is my biggest encouragement! ^_^
