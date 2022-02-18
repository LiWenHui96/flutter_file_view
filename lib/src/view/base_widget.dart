import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @Describe: Base Widgets
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/17

Widget baseIndicator(BuildContext context) {
  return Center(
    child: CupertinoTheme(
      data: CupertinoThemeData(brightness: Theme.of(context).brightness),
      child: const CupertinoActivityIndicator(radius: 14.0),
    ),
  );
}
