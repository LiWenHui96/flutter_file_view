import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'viewer_localizations.dart';

/// @Describe: LocalizationsDelegate
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class ViewerLocalizationsDelegate
    extends LocalizationsDelegate<ViewerLocalizations> {
  const ViewerLocalizationsDelegate();

  static const ViewerLocalizationsDelegate delegate =
      ViewerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ViewerLocalizations.languages.contains(locale.languageCode);

  @override
  Future<ViewerLocalizations> load(Locale locale) {
    return SynchronousFuture<ViewerLocalizations>(ViewerLocalizations(locale));
  }

  @override
  bool shouldReload(ViewerLocalizationsDelegate old) => false;
}
