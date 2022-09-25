import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: 本地文件视图
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/12
///

class FileViewPage extends StatefulWidget {
  const FileViewPage({Key? key, required this.controller}) : super(key: key);

  final FileViewController controller;

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("文档")),
      body: Column(
        children: [
          Expanded(child: FileView(controller: widget.controller)),
        ],
      ),
    );
  }
}
