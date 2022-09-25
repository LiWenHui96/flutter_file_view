import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'page_file_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FlutterFileView.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FileViewLocalizationsDelegate.delegate,
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

        final child = ElevatedButton(
          onPressed: () {
            FileViewController? controller;

            if (filePath.contains('http://') || filePath.contains('https://')) {
              controller = FileViewController.network(filePath);
            } else {
              controller = FileViewController.asset('assets/files/$filePath');
            }

            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return FileViewPage(controller: controller!);
            }));
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
}
