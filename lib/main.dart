import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/word_base.dart';
// TO RE-ENABLE LOGIN: uncomment the following import:
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/word_capture_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const VocaBuilderApp());
}

Future<void> _configureAmplify() async {
  try {
    final api = AmplifyAPI();
    await Amplify.addPlugins([api]);

    // Load the amplify_outputs.json from the app assets.
    final jsonString = await rootBundle.loadString('amplify_outputs.json');
    final config = jsonDecode(jsonString) as Map<String, dynamic>;
    await Amplify.configure(jsonEncode(config));

    safePrint('Successfully configured Amplify');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
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
