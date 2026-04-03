import 'package:flutter/material.dart';

/// Placeholder home page — navigated to after login.
/// This will be replaced with the real page flow
/// (Capture Vocab, Spaced Repetition, Crossword).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoCa Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to VoCa Builder!\nMore features coming soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
