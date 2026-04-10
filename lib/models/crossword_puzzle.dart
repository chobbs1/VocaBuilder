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

  /// Set focus to [row],[col]. If already focused, toggle direction.
  void setFocus(int row, int col) {
    if (grid[row][col].isBlock) return;

    if (isFocused(row, col)) {
      // Tapping the same cell toggles across ↔ down.
      activeDirection = activeDirection == ClueDirection.across
          ? ClueDirection.down
          : ClueDirection.across;
    } else {
      focusRow = row;
      focusCol = col;
    }
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

  /// Move focus forward by one cell in the active direction.
  void _advanceFocus() {
    if (focusRow == null || focusCol == null) return;
    int r = focusRow!;
    int c = focusCol!;

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

  // ───────────────────────── Demo puzzle ─────────────────────────

  /// Creates a small hard-coded 9×9 demo puzzle for development.
  /// 
  ///
  /// Legend:  `.` = block,  letter = solution.
  factory CrosswordPuzzle.demo() {
    const size = 9;
    //            0    1    2    3    4    5    6    7    8
    final layout = [
      'FLUTTER..', // row 0
      'L..A.....', // row 1
      'A..B.....', // row 2
      'WORDBASE.', // row 3
      'S..E.....', // row 4
      '...CLUE..', // row 5
      '.........', // row 6  (all blocks)
      'VOCAB....', // row 7
      'O........', // row 8
    ];

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
              text: 'Across clue $clueNum',
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
              text: 'Down clue $clueNum',
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
