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

  String get retry => getItem('retry').toString();

  String get engineFail => getItem('engineFail').toString();

  String get engineDownloadSuccess =>
      getItem('engineDownloadSuccess').toString();

  String get engineDownloadFail => getItem('engineDownloadFail').toString();

  String get engineDownloading => getItem('engineDownloading').toString();

  String get engineDownloadNonRequired =>
      getItem('engineDownloadNonRequired').toString();

  String get engineDownloadCancelNotWifi =>
      getItem('engineDownloadCancelNotWifi').toString();

  String get engineDownloadCancelRequesting =>
      getItem('engineDownloadCancelRequesting').toString();

  String get engineDownloadNoNeedRequest =>
      getItem('engineDownloadNoNeedRequest').toString();

  String get engineDownloadFlowCancel =>
      getItem('engineDownloadFlowCancel').toString();

  String get engineDownloadOutOfOne =>
      getItem('engineDownloadOutOfOne').toString();

  String get engineInstallSuccess => getItem('engineInstallSuccess').toString();

  String get engineInstallFail => getItem('engineInstallFail').toString();

  String get engineLoading => getItem('engineLoading').toString();
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
      'nonExistentTip': 'Non-existent file.',
      'unSupportedType': 'Does not support opening files of type %s.',
      'retry': 'Retry',
      'engineFail': 'Failed to initialize engine.',
      'engineDownloadSuccess':
          'Engine download is complete, please wait for installation.',
      'engineDownloadFail': 'Engine download failed, please try again.',
      'engineDownloading': 'Engine downloading, please wait.',
      'engineDownloadNonRequired':
          'The engine cannot be downloaded temporarily, please restart.',
      'engineDownloadCancelNotWifi': 'The engine has canceled the download,'
          ' please switch to a wireless network',
      'engineDownloadCancelRequesting': 'The engine has canceled the download,'
          ' please do not repeat the request.',
      'engineDownloadNoNeedRequest': 'Engine not downloading, please try again'
          ' later.',
      'engineDownloadFlowCancel': 'The download of the engine has been '
          'canceled, and the current network is abnormal.',
      'engineDownloadOutOfOne':
          'The engine has retried too many times, please restart.',
      'engineInstallSuccess':
          'Engine installation is complete, please wait for initialization.',
      'engineInstallFail': 'Engine installation failed, please try again.',
      'engineLoading': 'Engine initialization, please wait.',
    },
    'zh': <String, String>{
      'unSupportedPlatformTip': '仅支持Android和iOS平台',
      'nonExistentTip': '文件不存在',
      'unSupportedType': '不支持打开%s类型的文件',
      'retry': '重试',
      'engineFail': '引擎初始化失败',
      'engineDownloadSuccess': '引擎下载完成，请等待安装',
      'engineDownloadFail': '引擎下载失败，请重试',
      'engineDownloading': '引擎下载中，请稍候',
      'engineDownloadNonRequired': '引擎暂时无法下载，请重启',
      'engineDownloadCancelNotWifi': '引擎已取消下载，请改用无线网络',
      'engineDownloadCancelRequesting': '引擎已取消下载，请勿重复请求',
      'engineDownloadNoNeedRequest': '引擎未进行下载，请稍后重试',
      'engineDownloadFlowCancel': '引擎已取消下载，当前网络异常',
      'engineDownloadOutOfOne': '引擎重试次数过多，请重启',
      'engineInstallSuccess': '引擎安装完成，请等待初始化',
      'engineInstallFail': '引擎安装失败，请重试',
      'engineLoading': '引擎初始化中，请稍候',
    },
  };
}
