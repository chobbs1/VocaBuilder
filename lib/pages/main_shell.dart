import 'package:flutter/material.dart';

import '../models/word_base.dart';
import 'word_capture_page.dart';
import 'play_crossword_page.dart';
import 'spaced_repetition_page.dart';

/// Main navigation shell — displayed after login.
///
/// Hosts a [BottomNavigationBar] with tabs for:
///   0 – Capture Word  (landing / default)
///   1 – Play Crossword
///   2 – Spaced Repetition
///
/// Uses an [IndexedStack] so each tab's state is preserved when switching.
class MainShell extends StatefulWidget {
  final WordBase wordBase;

  const MainShell({super.key, required this.wordBase});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // 0 = Capture Word (default landing page)

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WordCapturePage(wordBase: widget.wordBase),
      const PlayCrosswordPage(),
      const SpacedRepetitionPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Capture Word',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Play Crossword',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            label: 'Spaced Repetition',
          ),
        ],
      ),
    );
  }
}
