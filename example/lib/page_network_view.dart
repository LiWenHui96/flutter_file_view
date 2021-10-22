import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

import 'page_file_view.dart';

///
/// @Describe: 网络链接视图
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/29
///

class FileNetworkViewPage extends StatefulWidget {
  final String downloadUrl;
  final String downloadPath;

  FileNetworkViewPage({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
  }) : super(key: key);

  @override
  _FileNetworkViewPageState createState() => _FileNetworkViewPageState();
}

class _FileNetworkViewPageState extends State<FileNetworkViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FileNetworkViewer(
        downloadUrl: widget.downloadUrl,
        downloadPath: widget.downloadPath,
        onViewPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) {
              return FileLocalViewPage(filePath: widget.downloadPath);
            },
          ));
        },
      ),
    );
  }
}
