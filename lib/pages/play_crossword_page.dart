import 'package:flutter/material.dart';

/// Play Crossword page — placeholder for the crossword game.
///
/// Per 0002-initial-architecture:
///   "Crossword Page: Takes the users WordBase and implements a crossword"
///
/// This page will eventually use the user's WordBase to generate
/// and display an interactive crossword puzzle.
class PlayCrosswordPage extends StatelessWidget {
  const PlayCrosswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Crossword'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_on,
              size: 80,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 24),
            Text(
              'Crossword coming soon!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your WordBase will be used to generate\nan interactive crossword puzzle.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
