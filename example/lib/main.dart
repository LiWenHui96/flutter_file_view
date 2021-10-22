import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view_example/page_network_view.dart';
import 'package:path_provider/path_provider.dart';

import 'page_file_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> iosFiles = [
    'docx.docx',
    'doc.doc',
    'xlsx.xlsx',
    'xls.xls',
    'pptx.pptx',
    'ppt.ppt',
    'pdf.pdf',
    'txt.txt',
    'jpg.jpg',
    'jpeg.jpeg',
    'png.png',
  ];

  List<String> androidFiles = [
    'docx.docx',
    'doc.doc',
    'xlsx.xlsx',
    'xls.xls',
    'pptx.pptx',
    'ppt.ppt',
    'pdf.pdf',
    'txt.txt',
  ];

  List<String> files = [];

  @override
  void initState() {
    if (Platform.isAndroid) {
      files = androidFiles;
    } else if (Platform.isIOS) {
      files = iosFiles;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('File View'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          String filePath = files[index];
          String fileShowText = '';

          int i = filePath.lastIndexOf('/');
          if (i <= -1) {
            fileShowText = filePath;
          } else {
            fileShowText = filePath.substring(i + 1);
          }

          int j = fileShowText.lastIndexOf('.');

          String title = '';
          String type = '';

          if (j > -1) {
            title = fileShowText.substring(0, j);
            type = fileShowText.substring(j + 1).toLowerCase();
          }

          return GestureDetector(
            onTap: () {
              if (filePath.contains('http://') ||
                  filePath.contains('https://')) {
                onNetworkTap(title, type, filePath);
              } else {
                onLocalTap(type, 'assets/files/$filePath');
              }
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 8.0),
              color: Theme.of(context).primaryColor,
              child: Text(
                fileShowText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        itemCount: files.length,
      ),
    );
  }

  onLocalTap(String type, String assetPath) async {
    String filePath = await setFilePath(type, assetPath);
    if (!await asset2Local(type, assetPath)) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return FileLocalViewPage(filePath: filePath);
    }));
  }

  onNetworkTap(String title, String type, String downloadUrl) async {
    String filePath = await setFilePath(type, title);

    if (await fileExists(filePath)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return FileLocalViewPage(filePath: filePath);
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return FileNetworkViewPage(
          downloadUrl: downloadUrl,
          downloadPath: filePath,
        );
      }));
    }
  }

  setFilePath(String type, String assetPath) async {
    final Directory _directory = await getTemporaryDirectory();
    String dic = "${_directory.path}/fileview/";
    return dic + base64.encode(utf8.encode(assetPath)) + "." + type;
  }

  fileExists(String filePath) async {
    if (await File(filePath).exists()) {
      return true;
    }
    return false;
  }

  asset2Local(String type, String assetPath) async {
    String filePath = await setFilePath(type, assetPath);

    File file = File(filePath);
    if (await fileExists(filePath)) {
      await file.delete();
    }

    await file.create(recursive: true);
    debugPrint("文件路径 -> " + file.path);
    ByteData bd = await rootBundle.load(assetPath);
    await file.writeAsBytes(bd.buffer.asUint8List(), flush: true);
    return true;
  }
}
