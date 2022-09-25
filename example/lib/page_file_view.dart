import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe: 本地文件视图
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/12

class FileViewPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const FileViewPage({Key? key, required this.controller}) : super(key: key);

  /// The [FileViewController] responsible for the file being rendered in this
  /// widget.
  final FileViewController controller;

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文档')),
      body: Column(
        children: <Widget>[
          Expanded(child: FileView(controller: widget.controller)),
        ],
      ),
    );
  }
}
