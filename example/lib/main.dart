import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'page_local_file_viewer.dart';
import 'page_network_file_viewer.dart';

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
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ViewerLocalizationsDelegate.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('zh', 'CN')],
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
  List<String> files = [
    'docx.docx',
    'doc.doc',
    'xlsx.xlsx',
    'xls.xls',
    'pptx.pptx',
    'ppt.ppt',
    'pdf.pdf',
    'txt.txt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File View')),
      body: _buildBodyWidget(),
    );
  }

  Widget _buildBodyWidget() {
    return ListView.builder(
      itemCount: files.length,
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

        final child = ElevatedButton(
          onPressed: () {
            if (filePath.contains('http://') || filePath.contains('https://')) {
              onNetworkTap(title, type, filePath);
            } else {
              onLocalTap(type, 'assets/files/$filePath');
            }
          },
          child: Text(fileShowText),
        );

        return Container(
          margin: const EdgeInsets.only(top: 10.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: child,
        );
      },
    );
  }

  Future onLocalTap(String type, String assetPath) async {
    String filePath = await setFilePath(type, assetPath);
    if (!await asset2Local(type, assetPath)) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return LocalFileViewerPage(filePath: filePath);
    }));
  }

  Future onNetworkTap(String title, String type, String downloadUrl) async {
    String filePath = await setFilePath(type, title);

    if (fileExists(filePath)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return LocalFileViewerPage(filePath: filePath);
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return NetworkFileViewerPage(
          downloadUrl: downloadUrl,
          downloadPath: filePath,
        );
      }));
    }
  }

  Future asset2Local(String type, String assetPath) async {
    String filePath = await setFilePath(type, assetPath);

    File file = File(filePath);
    if (fileExists(filePath)) {
      await file.delete();
    }

    await file.create(recursive: true);
    debugPrint("文件路径 -> " + file.path);
    ByteData bd = await rootBundle.load(assetPath);
    await file.writeAsBytes(bd.buffer.asUint8List(), flush: true);
    return true;
  }

  Future setFilePath(String type, String assetPath) async {
    final _directory = await getTemporaryDirectory();
    return "${_directory.path}/fileview/${base64.encode(utf8.encode(assetPath))}.$type";
  }

  bool fileExists(String filePath) => File(filePath).existsSync();
}
