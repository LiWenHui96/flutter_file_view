import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'page_file_view.dart';

void main() => runApp(const MyApp());

// ignore: public_member_api_docs
class MyApp extends StatefulWidget {
  // ignore: public_member_api_docs
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
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
      supportedLocales: <Locale>[Locale('en', 'US'), Locale('zh', 'CN')],
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// ignore: public_member_api_docs
class HomePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> files = <String>[
    'FileTest.docx',
    'FileTest.doc',
    'FileTest.xlsx',
    'FileTest.xls',
    'FileTest.pptx',
    'FileTest.ppt',
    'FileTest.pdf',
    'FileTest.txt',
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
      itemBuilder: (BuildContext context, int index) {
        final String filePath = files[index];
        String fileShowText = '';

        final int i = filePath.lastIndexOf('/');
        if (i <= -1) {
          fileShowText = filePath;
        } else {
          fileShowText = filePath.substring(i + 1);
        }

        final Widget child = ElevatedButton(
          onPressed: () {
            FileViewController? controller;

            if (filePath.contains('http://') || filePath.contains('https://')) {
              controller = FileViewController.network(filePath);
            } else {
              controller = FileViewController.asset('assets/files/$filePath');
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FileViewPage(controller: controller!),
              ),
            );
          },
          child: Text(fileShowText),
        );

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: child,
        );
      },
    );
  }
}
