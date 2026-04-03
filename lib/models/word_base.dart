import 'word_entry.dart';

/// The user's collection of words — their WordBase.
///
/// Currently stored in-memory. When a backend/database is added,
/// this class should be backed by persistent storage.
class WordBase {
  final List<WordEntry> _entries = [];

  /// All entries in the WordBase, newest first.
  List<WordEntry> get entries => List.unmodifiable(
        [..._entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  /// Number of words in the WordBase.
  int get length => _entries.length;

  /// Add a new word entry to the WordBase.
  void add(WordEntry entry) {
    _entries.add(entry);
  }

  /// Check if a word already exists in the WordBase (case-insensitive).
  bool contains(String word) {
    return _entries.any(
      (e) => e.word.toLowerCase() == word.toLowerCase(),
    );
  }

  /// Remove a word entry by its word string (case-insensitive).
  bool remove(String word) {
    final index = _entries.indexWhere(
      (e) => e.word.toLowerCase() == word.toLowerCase(),
    );
    if (index == -1) return false;
    _entries.removeAt(index);
    return true;
  }
}
