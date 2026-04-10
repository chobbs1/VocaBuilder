/// The visual/logical state of a crossword cell during play.
enum CellState {
  /// Default — no input yet.
  empty,

  /// The user has typed a letter but it hasn't been checked.
  filled,

  /// The cell has been checked and the answer is correct.
  correct,

  /// The cell has been checked and the answer is wrong.
  incorrect,

  /// The correct answer has been revealed for this cell.
  revealed,
}

/// The direction a clue runs.
enum ClueDirection { across, down }

/// Represents a single cell in a crossword grid, modelled after the
/// NYT-style crossword.
///
/// A cell is either a **block** (blacked-out, unplayable) or a
/// **letter cell** that the player can type into.
///
/// Letter cells may optionally carry a [clueNumber] — the small number
/// shown in the top-left corner indicating the start of an across and/or
/// down clue.
///
/// ```
/// ┌────────────┐
/// │ 3     ← clueNumber (nullable)
/// │      A     ← userInput (nullable)
/// │        [C] ← solution (the correct letter)
/// └────────────┘
/// ```
class CrosswordCell {
  /// Whether this cell is a blacked-out block (not playable).
  final bool isBlock;

  /// The correct letter for this cell (uppercase, A–Z).
  /// Null for blocks.
  final String? solution;

  /// The letter the player has entered so far (uppercase, A–Z).
  /// Null when empty or for blocks.
  String? userInput;

  /// The clue number displayed in the top-left of the cell.
  /// Non-null only for cells that start an across and/or down clue.
  final int? clueNumber;

  /// Which clue directions originate from this cell.
  /// E.g. a cell can start both an across AND a down clue.
  final Set<ClueDirection> clueStarts;

  /// The current visual/logical state of the cell.
  CellState state;

  CrosswordCell({
    this.isBlock = false,
    this.solution,
    this.userInput,
    this.clueNumber,
    Set<ClueDirection>? clueStarts,
    this.state = CellState.empty,
  }) : clueStarts = clueStarts ?? {};

  /// Convenience: is this cell a playable letter cell?
  bool get isLetterCell => !isBlock;

  /// Whether the user's input matches the solution.
  bool get isCorrect =>
      isLetterCell &&
      userInput != null &&
      solution != null &&
      userInput == solution;

  /// Clear the user's input and reset state to [CellState.empty].
  void clear() {
    userInput = null;
    state = CellState.empty;
  }
}
