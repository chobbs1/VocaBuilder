import 'crossword_cell.dart';

/// A single clue entry (number + text).
class CrosswordClue {
  final int number;
  final String text;
  final ClueDirection direction;

  /// Grid position where this clue starts.
  final int startRow;
  final int startCol;

  /// How many letter cells this clue spans.
  final int length;

  const CrosswordClue({
    required this.number,
    required this.text,
    required this.direction,
    required this.startRow,
    required this.startCol,
    required this.length,
  });
}

/// A word↔clue pair with its grid position.
///
/// Used as input to [CrosswordPuzzle.generateLayout] to build the
/// crossword grid. The direction (across/down) is determined by which
/// list the entry is placed in.
class ClueEntry {
  final String word;
  final String clue;
  final int startRow;
  final int startCol;

  const ClueEntry({
    required this.word,
    required this.clue,
    required this.startRow,
    required this.startCol,
  });
}

/// Holds the full state of a crossword puzzle.
///
/// The grid is [rows] × [cols] (default 10×10) of [CrosswordCell] objects.
///
/// Tracks:
///   - The grid data itself
///   - Across and down clues
///   - The currently focused cell ([focusRow], [focusCol])
///   - The active clue direction ([activeDirection])
///
/// Provides helpers for navigation, input, checking, and revealing.
class CrosswordPuzzle {
  final int rows;
  final int cols;

  /// The 2-D grid, accessed as `grid[row][col]`.
  final List<List<CrosswordCell>> grid;

  /// Clues keyed by direction.
  final List<CrosswordClue> acrossClues;
  final List<CrosswordClue> downClues;

  /// Currently focused cell (nullable when nothing is selected).
  int? focusRow;
  int? focusCol;

  /// Whether the player is currently entering across or down.
  ClueDirection activeDirection;

  CrosswordPuzzle({
    required this.rows,
    required this.cols,
    required this.grid,
    this.acrossClues = const [],
    this.downClues = const [],
    this.focusRow,
    this.focusCol,
    this.activeDirection = ClueDirection.across,
  });

  // ───────────────────────── Focus helpers ─────────────────────────

  /// Whether a specific cell is the currently focused cell.
  bool isFocused(int row, int col) => focusRow == row && focusCol == col;

  /// Set focus to [row],[col]. If already focused, toggle direction —
  /// but only if the cell is at an intersection (part of both an across
  /// and a down word). Otherwise tapping the same cell is a no-op.
  void setFocus(int row, int col) {
    if (grid[row][col].isBlock) return;

    if (isFocused(row, col)) {
      // Only toggle if this cell participates in both directions.
      if (_isIntersection(row, col)) {
        activeDirection = activeDirection == ClueDirection.across
            ? ClueDirection.down
            : ClueDirection.across;
      }
    } else {
      focusRow = row;
      focusCol = col;

      // Auto-switch direction to match the new cell's word.
      // If the cell only belongs to one direction, snap to it.
      final hasHorizontal =
          (col > 0 && grid[row][col - 1].isLetterCell) ||
          (col + 1 < cols && grid[row][col + 1].isLetterCell);
      final hasVertical =
          (row > 0 && grid[row - 1][col].isLetterCell) ||
          (row + 1 < rows && grid[row + 1][col].isLetterCell);

      if (hasHorizontal && !hasVertical) {
        activeDirection = ClueDirection.across;
      } else if (hasVertical && !hasHorizontal) {
        activeDirection = ClueDirection.down;
      }
      // If both (intersection) — keep the current activeDirection.
    }
  }

  /// Returns true if the cell at [row],[col] is part of both an across
  /// word (≥2 consecutive horizontal letter cells) and a down word
  /// (≥2 consecutive vertical letter cells).
  bool _isIntersection(int row, int col) {
    if (grid[row][col].isBlock) return false;

    // Check horizontal: at least one neighbour left or right.
    final hasHorizontal =
        (col > 0 && grid[row][col - 1].isLetterCell) ||
        (col + 1 < cols && grid[row][col + 1].isLetterCell);

    // Check vertical: at least one neighbour above or below.
    final hasVertical =
        (row > 0 && grid[row - 1][col].isLetterCell) ||
        (row + 1 < rows && grid[row + 1][col].isLetterCell);

    return hasHorizontal && hasVertical;
  }

  /// Returns the list of (row, col) pairs that belong to the same word as
  /// the currently focused cell, in the [activeDirection].
  List<(int, int)> get activeWordCells {
    if (focusRow == null || focusCol == null) return [];
    final r = focusRow!;
    final c = focusCol!;
    if (grid[r][c].isBlock) return [];

    final cells = <(int, int)>[];

    if (activeDirection == ClueDirection.across) {
      // Walk left to find the start of the word.
      int startCol = c;
      while (startCol > 0 && grid[r][startCol - 1].isLetterCell) {
        startCol--;
      }
      // Walk right to collect all cells.
      for (int cc = startCol; cc < cols && grid[r][cc].isLetterCell; cc++) {
        cells.add((r, cc));
      }
    } else {
      // Walk up to find the start of the word.
      int startRow = r;
      while (startRow > 0 && grid[startRow - 1][c].isLetterCell) {
        startRow--;
      }
      // Walk down to collect all cells.
      for (int rr = startRow; rr < rows && grid[rr][c].isLetterCell; rr++) {
        cells.add((rr, c));
      }
    }

    return cells;
  }

  /// Whether [row],[col] is part of the currently highlighted word.
  bool isInActiveWord(int row, int col) {
    return activeWordCells.contains((row, col));
  }

  /// Returns the [CrosswordClue] for the currently focused cell and
  /// [activeDirection], or `null` if no clue is found.
  CrosswordClue? get activeClue {
    final cells = activeWordCells;
    if (cells.isEmpty) return null;

    // The clue starts at the first cell in the active word.
    final (startRow, startCol) = cells.first;

    final clues = activeDirection == ClueDirection.across
        ? acrossClues
        : downClues;

    for (final clue in clues) {
      if (clue.startRow == startRow && clue.startCol == startCol) {
        return clue;
      }
    }
    return null;
  }

  // ───────────────────────── Input helpers ─────────────────────────

  /// Enter a letter into the focused cell and advance to the next cell
  /// in the active direction.
  void enterLetter(String letter) {
    if (focusRow == null || focusCol == null) return;
    final cell = grid[focusRow!][focusCol!];
    if (cell.isBlock) return;

    cell.userInput = letter.toUpperCase();
    cell.state = CellState.filled;

    _advanceFocus();
  }

  /// Delete the letter in the focused cell (or move back if already empty).
  void deleteLetter() {
    if (focusRow == null || focusCol == null) return;
    final cell = grid[focusRow!][focusCol!];
    if (cell.isBlock) return;

    if (cell.userInput != null) {
      cell.clear();
    } else {
      _retreatFocus();
    }
  }

  /// Move focus forward to the next **empty** letter cell in the active
  /// direction, skipping over cells that already have input.
  /// Stops at the end of the word if no empty cell is found.
  void _advanceFocus() {
    if (focusRow == null || focusCol == null) return;
    int r = focusRow!;
    int c = focusCol!;

    while (true) {
      if (activeDirection == ClueDirection.across) {
        c++;
      } else {
        r++;
      }

      // Stop if we've left the grid or hit a block.
      if (r >= rows || c >= cols || grid[r][c].isBlock) break;

      // Land on the first empty cell.
      if (grid[r][c].userInput == null) {
        focusRow = r;
        focusCol = c;
        return;
      }
    }

    // No empty cell ahead — stay on the cell right after the one we typed in.
    // (Reset to one step forward from original position.)
    r = focusRow!;
    c = focusCol!;
    if (activeDirection == ClueDirection.across) {
      c++;
    } else {
      r++;
    }
    if (r < rows && c < cols && grid[r][c].isLetterCell) {
      focusRow = r;
      focusCol = c;
    }
  }

  /// Move focus backward by one cell in the active direction.
  void _retreatFocus() {
    if (focusRow == null || focusCol == null) return;
    int r = focusRow!;
    int c = focusCol!;

    if (activeDirection == ClueDirection.across) {
      c--;
    } else {
      r--;
    }

    if (r >= 0 && c >= 0 && grid[r][c].isLetterCell) {
      focusRow = r;
      focusCol = c;
    }
  }

  // ───────────────────────── Check / Reveal ─────────────────────────

  /// Check all filled cells and mark them correct or incorrect.
  void checkAll() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isLetterCell && cell.userInput != null) {
          cell.state = cell.isCorrect ? CellState.correct : CellState.incorrect;
        }
      }
    }
  }

  /// Reveal the solution for every cell.
  void revealAll() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isLetterCell && cell.solution != null) {
          cell.userInput = cell.solution;
          cell.state = CellState.revealed;
        }
      }
    }
  }

  /// Clear all user input.
  void clearAll() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isLetterCell) {
          cell.clear();
        }
      }
    }
  }

  // ───────────────────────── Layout generator ─────────────────────────

  /// Generates a layout string array and a clue text lookup from two
  /// typed [ClueEntry] lists.
  ///
  /// [size] is the grid dimension (size × size).
  ///
  /// Returns a record of `(layout, clueTexts)` where:
  ///   - `layout` is a `List<String>` of length [size], each string of
  ///     length [size], with letters for filled cells and `.` for blocks.
  ///   - `clueTexts` maps `(row, col, ClueDirection)` → clue text.
  static ({
    List<String> layout,
    Map<(int, int, ClueDirection), String> clueTexts,
  }) generateLayout({
    required int size,
    required List<ClueEntry> across,
    required List<ClueEntry> down,
  }) {
    // Start with an all-blocks grid.
    final grid = List.generate(size, (_) => List.filled(size, '.'));

    // Place across words.
    for (final entry in across) {
      for (int i = 0; i < entry.word.length; i++) {
        grid[entry.startRow][entry.startCol + i] = entry.word[i];
      }
    }

    // Place down words.
    for (final entry in down) {
      for (int i = 0; i < entry.word.length; i++) {
        grid[entry.startRow + i][entry.startCol] = entry.word[i];
      }
    }

    // Build layout strings.
    final layout = grid.map((row) => row.join()).toList();

    // Build clue text lookup.
    final clueTexts = <(int, int, ClueDirection), String>{};
    for (final entry in across) {
      clueTexts[(entry.startRow, entry.startCol, ClueDirection.across)] =
          entry.clue;
    }
    for (final entry in down) {
      clueTexts[(entry.startRow, entry.startCol, ClueDirection.down)] =
          entry.clue;
    }

    return (layout: layout, clueTexts: clueTexts);
  }

  // ───────────────────────── Demo puzzle ─────────────────────────

  /// Creates a small hard-coded 9×9 demo puzzle for development.
  ///
  /// Word↔clue pairs are defined in one clear list, and
  /// [generateLayout] builds the layout grid from them.
  factory CrosswordPuzzle.demo() {
    const size = 9;

    final across = [
      ClueEntry(word: 'FLUTTER',  clue: "Placing a bet (Aus. slang)",             startRow: 0, startCol: 0),
      ClueEntry(word: 'WORDBASE', clue: 'Your personal vocabulary store',  startRow: 3, startCol: 0),
      ClueEntry(word: 'RAGE',     clue: 'Fit of anger', startRow: 5, startCol: 3),
      ClueEntry(word: 'FIELD',    clue: 'Answer a question',            startRow: 7, startCol: 0),
    ];

    final down = [
      ClueEntry(word: 'FLAWS', clue: 'Imperfections or defects', startRow: 0, startCol: 0),
      ClueEntry(word: 'TINDER', clue: 'A popular dating app',   startRow: 0, startCol: 3),
      ClueEntry(word: 'FI',    clue: 'Fidelity (abbr.)',       startRow: 7, startCol: 0),
    ];

    final (:layout, :clueTexts) = generateLayout(
      size: size,
      across: across,
      down: down,
    );

    final grid = <List<CrosswordCell>>[];
    for (int r = 0; r < size; r++) {
      final row = <CrosswordCell>[];
      for (int c = 0; c < size; c++) {
        final ch = layout[r][c];
        if (ch == '.') {
          row.add(CrosswordCell(isBlock: true));
        } else {
          row.add(CrosswordCell(solution: ch));
        }
      }
      grid.add(row);
    }

    // Assign clue numbers — scan left→right, top→bottom.
    int clueNum = 0;
    final acrossClues = <CrosswordClue>[];
    final downClues = <CrosswordClue>[];

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].isBlock) continue;

        final startsAcross =
            (c == 0 || grid[r][c - 1].isBlock) &&
            c + 1 < size &&
            grid[r][c + 1].isLetterCell;

        final startsDown =
            (r == 0 || grid[r - 1][c].isBlock) &&
            r + 1 < size &&
            grid[r + 1][c].isLetterCell;

        if (startsAcross || startsDown) {
          clueNum++;
          grid[r][c] = CrosswordCell(
            solution: grid[r][c].solution,
            clueNumber: clueNum,
            clueStarts: {
              if (startsAcross) ClueDirection.across,
              if (startsDown) ClueDirection.down,
            },
          );

          if (startsAcross) {
            int len = 0;
            for (int cc = c; cc < size && grid[r][cc].isLetterCell; cc++) {
              len++;
            }
            acrossClues.add(CrosswordClue(
              number: clueNum,
              text: clueTexts[(r, c, ClueDirection.across)] ?? '',
              direction: ClueDirection.across,
              startRow: r,
              startCol: c,
              length: len,
            ));
          }
          if (startsDown) {
            int len = 0;
            for (int rr = r; rr < size && grid[rr][c].isLetterCell; rr++) {
              len++;
            }
            downClues.add(CrosswordClue(
              number: clueNum,
              text: clueTexts[(r, c, ClueDirection.down)] ?? '',
              direction: ClueDirection.down,
              startRow: r,
              startCol: c,
              length: len,
            ));
          }
        }
      }
    }

    return CrosswordPuzzle(
      rows: size,
      cols: size,
      grid: grid,
      acrossClues: acrossClues,
      downClues: downClues,
    );
  }
}
