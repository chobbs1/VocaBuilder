/// Represents a single entry in the user's WordBase.
///
/// See architectural-design-record and .claude/0002-initial-architecture
/// for the full data structure specification.
class WordEntry {
  /// The word itself — a single valid English word, entered by the user.
  final String word;

  /// A dictionary definition of the word.
  /// Not user input — fetched from a dictionary source.
  /// Only clarified if the word has multiple meanings.
  /// For now, stored as user-provided until a dictionary API is integrated.
  String? definition;

  /// A set of possible crossword clues associated with the word.
  /// Not user input — generated or fetched.
  /// Only clarified if the word has multiple meanings.
  /// For now, stored as user-provided until a clue source is integrated.
  List<String> crosswordClues;

  /// Free-form associations the user has with this word.
  /// User input text field.
  /// TODO: To be fully implemented in a future iteration.
  String? associations;

  /// Timestamp when the word was added to the WordBase.
  final DateTime createdAt;

  WordEntry({
    required this.word,
    this.definition,
    List<String>? crosswordClues,
    this.associations,
    DateTime? createdAt,
  })  : crosswordClues = crosswordClues ?? [],
        createdAt = createdAt ?? DateTime.now();

  @override
  String toString() => 'WordEntry(word: $word)';
}
