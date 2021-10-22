import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: 本地文件视图
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/12
///

class FileLocalViewPage extends StatefulWidget {
  final String filePath;

  FileLocalViewPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _FileLocalViewPageState createState() => _FileLocalViewPageState();
}

class _FileLocalViewPageState extends State<FileLocalViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text("文档"),
      ),
      body: FileLocalViewer(localFilePath: widget.filePath),
    );
  }
}
