// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// @Describe: LocalizationsDelegate
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class FileViewLocalizationsDelegate
    extends LocalizationsDelegate<FileViewLocalizations> {
  const FileViewLocalizationsDelegate();

  /// Provided to [MaterialApp] for use.
  static const FileViewLocalizationsDelegate delegate =
      FileViewLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      FileViewLocalizations.languages.contains(locale.languageCode);

  @override
  Future<FileViewLocalizations> load(Locale locale) {
    return SynchronousFuture<FileViewLocalizations>(
      FileViewLocalizations(locale),
    );
  }

  @override
  bool shouldReload(FileViewLocalizationsDelegate old) => false;
}

/// Localizations
abstract class FileViewLocalizationsBase {
  const FileViewLocalizationsBase(this.locale);

  final Locale? locale;

  Object? getItem(String key);

  String get unSupportedPlatformTip =>
      getItem('unSupportedPlatformTip').toString();

  String get nonExistentTip => getItem('nonExistentTip').toString();

  String get unSupportedType => getItem('unSupportedType').toString();

  String get engineLoading => getItem('engineLoading').toString();

  String get engineFail => getItem('engineFail').toString();

  String get downloadTitle => getItem('downloadTitle').toString();

  String get viewTitle => getItem('viewTitle').toString();
}

/// localizations
class FileViewLocalizations extends FileViewLocalizationsBase {
  const FileViewLocalizations(Locale? locale) : super(locale);

  static const FileViewLocalizations _static = FileViewLocalizations(null);

  @override
  Object? getItem(String key) {
    Map<String, Object>? localData;
    if (locale != null) {
      localData = localizedValues[locale!.languageCode];
    }
    if (localData == null) {
      return localizedValues['zh']![key];
    }
    return localData[key];
  }

  static FileViewLocalizations of(BuildContext context) {
    return Localizations.of<FileViewLocalizations>(
          context,
          FileViewLocalizations,
        ) ??
        _static;
  }

  /// Language Support
  static const List<String> languages = <String>['en', 'zh'];

  /// Language Values
  static const Map<String, Map<String, Object>> localizedValues =
      <String, Map<String, Object>>{
    'en': <String, String>{
      'unSupportedPlatformTip': 'Only supports Android and iOS platforms.',
      'nonExistentTip': 'Non-existent file',
      'unSupportedType': 'Does not support opening files of type %s',
      'engineLoading': 'Engine initializing, please wait...',
      'engineFail': 'The engine failed to load, please restart the app',
      'downloadTitle': 'Download',
      'viewTitle': 'View'
    },
    'zh': <String, String>{
      'unSupportedPlatformTip': '仅支持Android和iOS平台',
      'nonExistentTip': '文件不存在',
      'unSupportedType': '不支持打开%s类型的文件',
      'engineLoading': '引擎初始化中，请稍候...',
      'engineFail': '引擎加载失败，请重启App',
      'downloadTitle': '文件下载',
      'viewTitle': '文件查看'
    },
  };
}
