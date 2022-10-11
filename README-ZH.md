# Flutter File View

[![pub package](https://img.shields.io/pub/v/flutter_file_view)](https://pub.dev/packages/flutter_file_view)

Language: 中文 | [English](README.md)

> 目前该插件仅限于 Android，iOS 使用
>
> Android 由 [Tencent X5](https://x5.tencent.com/docs/index.html) 实现
>
> iOS 由 [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) 实现

## ✅ 所支持的文件类型

* Android `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`
* iOS `docx,doc,xlsx,xls,pptx,ppt,pdf,txt`

## ⏰ 初始化

```dart
FlutterFileView.init();
```

## 💼 2.0.x -> 2.1.0

### 过时的方案

```dart
@override
Widget build(BuildContext context) {
  return LocalFileViewer(filePath: localPath ?? '');
}
```

### 目前的方案

```dart
@override
Widget build(BuildContext context) {
  return FileView(
    controller: FileViewController.asset('assets/files/$filePath'),
  );
}
```

当前 FileViewController 的用法还有很多，比如一些状态的表述等等。

## 📲 第三方使用

* 使用 `dio` 进行网络请求。

## ⏳ 准备工作

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

## 🤖 Android

### Android P 无法下载内核解决方案

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

### 注意事项

- 后续TBS将不会再有升级，具体原因请查看 [TBS-文档接口TbsReaderView接口问题说明](https://doc.weixin.qq.com/doc/w3_AGoAtwbdAFw5hQq0KqWRPmmRF18F3?scode=AJEAIQdfAAo7OBDhdiAGoAtwbdAFw)
- 不支持Google Play，原因：[问题 1.11](https://x5.tencent.com/docs/questions.html)
- 不支持在Android 模拟器

> 如果你喜欢我的项目，请在项目右上角 "Star" 一下。你的支持是我最大的鼓励！ ^_^
