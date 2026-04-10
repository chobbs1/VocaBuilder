import 'package:flutter/material.dart';

/// Spaced Repetition page — placeholder for the spaced repetition review.
///
/// Per 0002-initial-architecture:
///   "Spaced Repition Page: Takes the users WordBase"
///
/// This page will eventually present words from the user's WordBase
/// using a spaced repetition algorithm for effective vocabulary retention.
class SpacedRepetitionPage extends StatelessWidget {
  const SpacedRepetitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaced Repetition'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.replay,
              size: 80,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 24),
            Text(
              'Spaced Repetition coming soon!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Review words from your WordBase using\nspaced repetition for better retention.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
