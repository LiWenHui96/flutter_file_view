import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: 本地文件视图
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/12
///

class LocalFileViewerPage extends StatefulWidget {
  final String filePath;

  const LocalFileViewerPage({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  _LocalFileViewerPageState createState() => _LocalFileViewerPageState();
}

class _LocalFileViewerPageState extends State<LocalFileViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("文档")),
      body: LocalFileViewer(filePath: widget.filePath),
    );
  }
}
