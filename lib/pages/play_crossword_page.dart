import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crossword_cell.dart';
import '../models/crossword_puzzle.dart';

/// Play Crossword page — renders an interactive 10×10 crossword grid.
///
/// Per 0002-initial-architecture:
///   "Crossword Page: Takes the users WordBase and implements a crossword"
///
/// Tapping a letter cell selects it and highlights the active word.
/// Tapping the same cell again toggles between across and down.
/// Blocks are rendered as solid dark cells.
class PlayCrosswordPage extends StatefulWidget {
  const PlayCrosswordPage({super.key});

  @override
  State<PlayCrosswordPage> createState() => _PlayCrosswordPageState();
}

class _PlayCrosswordPageState extends State<PlayCrosswordPage> {
  late final CrosswordPuzzle _puzzle;
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _puzzle = CrosswordPuzzle.demo();
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    debugPrint('[_onCellTap] row=$row col=$col');
    setState(() {
      _puzzle.setFocus(row, col);
    });
    // Reset the hidden text field and request focus so the keyboard opens.
    _inputController.text = ' '; // seed with a character so backspace has something to delete
    _inputController.selection = const TextSelection.collapsed(offset: 1);
    _inputFocusNode.requestFocus();
    debugPrint('[_onCellTap] focus=${_puzzle.focusRow},${_puzzle.focusCol} dir=${_puzzle.activeDirection}');
  }

  /// Handles raw key events to catch backspace reliably.
  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    debugPrint('[_onKeyEvent] key=${event.logicalKey.keyLabel}');

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      debugPrint('[_onKeyEvent] BACKSPACE');
      setState(() {
        _puzzle.deleteLetter();
      });
      // Re-seed so the next backspace still has something to delete.
      _inputController.text = ' ';
      _inputController.selection = const TextSelection.collapsed(offset: 1);
      debugPrint('[_onKeyEvent] after delete: focus=${_puzzle.focusRow},${_puzzle.focusCol}');
    }
  }

  /// Called whenever the hidden TextField value changes (letter input).
  void _onTextChanged(String value) {
    debugPrint('[_onTextChanged] value="$value" (length=${value.length})');
    // Extract the newly typed character (ignore the seed space).
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.isNotEmpty) {
      final letter = cleaned[cleaned.length - 1];
      debugPrint('[_onTextChanged] letter="$letter"');
      if (RegExp(r'[a-zA-Z]').hasMatch(letter)) {
        setState(() {
          _puzzle.enterLetter(letter);
        });
        debugPrint('[_onTextChanged] after enter: focus=${_puzzle.focusRow},${_puzzle.focusCol}');

        // Auto-check when the grid is fully filled.
        if (_puzzle.isFull) {
          _puzzle.checkAll();
          if (_puzzle.isAllCorrect) {
            // Dismiss keyboard and show victory dialog.
            _inputFocusNode.unfocus();
            _showVictoryDialog();
          } else {
            setState(() {}); // Refresh to show incorrect markers.
          }
        }
      }
    }
    // Re-seed with a single space so backspace always has something to act on.
    _inputController.text = ' ';
    _inputController.selection = const TextSelection.collapsed(offset: 1);
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Congratulations!'),
          ],
        ),
        content: const Text(
          'You solved the crossword! 🎉',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              _resetPuzzle();
            },
            child: const Text('Play Again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              // Navigate back to Capture Word (index 0 of MainShell).
              // The MainShell is the parent, so we pop to it or
              // use the bottom nav. Simplest: pop to root.
              Navigator.of(this.context).popUntil((route) => route.isFirst);
              Navigator.of(this.context).pushReplacementNamed('/word-capture');
            },
            child: const Text('Back to WordBase'),
          ),
        ],
      ),
    );
  }

  void _resetPuzzle() {
    setState(() {
      _puzzle.clearAll();
      _puzzle.focusRow = null;
      _puzzle.focusCol = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Play Crossword'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Check answers',
            onPressed: () => setState(() => _puzzle.checkAll()),
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'Reveal all',
            onPressed: () => setState(() => _puzzle.revealAll()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear all',
            onPressed: () => setState(() => _puzzle.clearAll()),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Hidden TextField to capture keyboard input.
          // Positioned off-screen so it's invisible but still focusable.
          Positioned(
            left: -300,
            top: -300,
            child: SizedBox(
              width: 1,
              height: 1,
              child: KeyboardListener(
                focusNode: FocusNode(), // passive listener
                onKeyEvent: _onKeyEvent,
                child: TextField(
                  focusNode: _inputFocusNode,
                  controller: _inputController,
                  autofocus: false,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: _onTextChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          // Main content — sized to fit above the keyboard.
          Column(
            children: [
              // ── Active clue (top) ──
              Builder(builder: (context) {
                if (_puzzle.focusRow == null ||
                    _puzzle.focusCol == null) {
                  return const SizedBox.shrink();
                }
                final clue = _puzzle.activeClue;
                final direction =
                    _puzzle.activeDirection == ClueDirection.across
                        ? 'Across'
                        : 'Down';
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  color: colorScheme.primaryContainer,
                  child: Text(
                    clue != null
                        ? '${clue.number} $direction: ${clue.text}'
                        : direction,
                    style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                );
              }),

              // ── Crossword grid ──
              // Expanded so the grid fills whatever space remains
              // above the keyboard, keeping everything visible.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      8.0, 8.0, 8.0, 8.0 + bottomInset),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize =
                              constraints.maxWidth / _puzzle.cols;
                          return GridView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _puzzle.cols,
                            ),
                            itemCount: _puzzle.rows * _puzzle.cols,
                            itemBuilder: (context, index) {
                              final row = index ~/ _puzzle.cols;
                              final col = index % _puzzle.cols;
                              final cell = _puzzle.grid[row][col];

                              return _CrosswordCellWidget(
                                cell: cell,
                                cellSize: cellSize,
                                isFocused:
                                    _puzzle.isFocused(row, col),
                                isInActiveWord:
                                    _puzzle.isInActiveWord(row, col),
                                colorScheme: colorScheme,
                                onTap: () => _onCellTap(row, col),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Individual cell widget
// ─────────────────────────────────────────────────────────────────────

class _CrosswordCellWidget extends StatelessWidget {
  final CrosswordCell cell;
  final double cellSize;
  final bool isFocused;
  final bool isInActiveWord;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _CrosswordCellWidget({
    required this.cell,
    required this.cellSize,
    required this.isFocused,
    required this.isInActiveWord,
    required this.colorScheme,
    required this.onTap,
  });

  Color _backgroundColor() {
    if (cell.isBlock) return Colors.black87;
    if (isFocused) return colorScheme.primary.withAlpha(100);
    if (isInActiveWord) return colorScheme.primary.withAlpha(40);

    switch (cell.state) {
      case CellState.correct:
        return Colors.green.withAlpha(50);
      case CellState.incorrect:
        return Colors.red.withAlpha(50);
      case CellState.revealed:
        return Colors.orange.withAlpha(50);
      default:
        return Colors.white;
    }
  }

  Color _textColor() {
    switch (cell.state) {
      case CellState.incorrect:
        return Colors.red;
      case CellState.revealed:
        return Colors.orange.shade700;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cell.isBlock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor(),
          border: Border.all(
            color: isFocused ? colorScheme.primary : Colors.grey.shade400,
            width: isFocused ? 2.0 : 0.5,
          ),
        ),
        child: cell.isBlock
            ? null
            : Stack(
                children: [
                  // Clue number (top-left)
                  if (cell.clueNumber != null)
                    Positioned(
                      top: 1,
                      left: 2,
                      child: Text(
                        '${cell.clueNumber}',
                        style: TextStyle(
                          fontSize: cellSize * 0.22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                  // User input letter (centred)
                  if (cell.userInput != null)
                    Center(
                      child: Text(
                        cell.userInput!,
                        style: TextStyle(
                          fontSize: cellSize * 0.48,
                          fontWeight: FontWeight.bold,
                          color: _textColor(),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
