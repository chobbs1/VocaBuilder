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
    setState(() {
      _puzzle.setFocus(row, col);
    });
    // Reset the hidden text field and request focus so the keyboard opens.
    _inputController.clear();
    _inputFocusNode.requestFocus();
  }

  /// Called whenever the hidden TextField value changes.
  /// We grab the last character typed and feed it into the puzzle.
  void _onTextChanged(String value) {
    if (value.isEmpty) {
      // User pressed backspace.
      setState(() {
        _puzzle.deleteLetter();
      });
    } else {
      // Take only the last character entered.
      final letter = value[value.length - 1];
      if (RegExp(r'[a-zA-Z]').hasMatch(letter)) {
        setState(() {
          _puzzle.enterLetter(letter);
        });
      }
    }
    // Reset the controller so the next keystroke is cleanly detected.
    _inputController.clear();
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
              child: TextField(
                focusNode: _inputFocusNode,
                controller: _inputController,
                autofocus: false,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
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
