import 'package:flutter/material.dart';
import 'models/word_base.dart';
// TO RE-ENABLE LOGIN: uncomment the following import:
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/word_capture_page.dart';

void main() {
  runApp(const VocaBuilderApp());
}

class VocaBuilderApp extends StatefulWidget {
  const VocaBuilderApp({super.key});

  @override
  State<VocaBuilderApp> createState() => _VocaBuilderAppState();
}

class _VocaBuilderAppState extends State<VocaBuilderApp> {
  /// The user's WordBase — shared across pages.
  /// When a backend is added, this should be loaded from persistent storage
  /// after authentication.
  final WordBase _wordBase = WordBase();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoCa Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/word-capture': (context) => WordCapturePage(wordBase: _wordBase),
      },
    );
  }
}
