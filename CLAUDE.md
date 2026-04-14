# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VoCa Builder is a Flutter vocabulary learning app targeting Android, iOS, and web. Users capture words into a personal WordBase, then learn them via a crossword puzzle and (future) spaced repetition. Backend is AWS Amplify (AppSync GraphQL + DynamoDB + Cognito).

Flutter version: **3.41.6 / Dart 3.11.4**

## Commands

```bash
# Run on a connected device / emulator
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze for linting issues
flutter analyze

# Build for Android
flutter build apk

# Build for web
flutter build web
```

## Architecture

### State and data flow

`WordBase` is instantiated in `main.dart` (`_VocaBuilderAppState`) and passed down to `MainShell` → `WordCapturePage`. It is currently **in-memory only**; persistence via Amplify/DynamoDB is a planned next step.

### Navigation

- `/` → `LoginPage` (email + password; signup not yet implemented)
- `/word-capture` → `MainShell` (bottom nav shell with `IndexedStack` — preserves tab state)

### Pages (inside `MainShell`)
| Index | Page | Status |
|-------|------|--------|
| 0 | `WordCapturePage` | Active |
| 1 | `PlayCrosswordPage` | Active |
| 2 | `SpacedRepetitionPage` | Stub / unimplemented |

### Key models

- **`WordEntry`** (`lib/models/word_entry.dart`) — a single vocabulary word with optional `definition`, `crosswordClues`, and `associations`.
- **`WordBase`** (`lib/models/word_base.dart`) — in-memory list of `WordEntry` objects; sorted newest-first on access.
- **`CrosswordPuzzle`** (`lib/models/crossword_puzzle.dart`) — holds the full grid state (`CrosswordCell` objects), clue lists, focus position, and active direction. Contains all game logic: focus management, letter entry, backspace, auto-advance to next clue, check/reveal/clear.
- **`CrosswordCell`** (`lib/models/crossword_cell.dart`) — individual cell state (solution letter, user input, `CellState`, clue number).

### Crossword layout

`CrosswordPuzzle.generateLayout()` is a static helper that takes typed `ClueEntry` lists (across + down) and produces a `List<String>` layout plus a `(row, col, direction) → clueText` map. `CrosswordPuzzle.demo()` uses it to build a hard-coded 9×9 puzzle; real puzzles from the user's WordBase are not yet wired up.

### Backend

Configured via `amplify_outputs.json` (gitignored — copy from the Amplify console for local dev). `ApiService` (`lib/services/api_service.dart`) sends raw GraphQL mutations to AppSync — no generated model classes.

### Keyboard input (crossword)

`PlayCrosswordPage` uses an **off-screen hidden `TextField`** seeded with a space character to capture mobile keyboard input. Backspace is caught via a `KeyboardListener` wrapping that field. This avoids focus fighting with the visual grid cells.

## Context files

`.claude/context/` contains design notes that inform ongoing work:
- `0002-initial-architecture.md` — data structures and page flow spec
- `0003-backend-design.md` — AWS Amplify / Cognito / DynamoDB decisions
- `0005-parsing-dictionary-dataset copy.md` — dictionary data pipeline notes
- `0006-crossword-renderer.md` — crossword rendering decisions

## AI pipeline (`pipeline.py`)

A Python script that chains Anthropic API agents (planner → refiner → implementer → reviewer → committer) for autonomous feature implementation. Run with:

```bash
python pipeline.py "Your task description here"
```

Requires `ANTHROPIC_API_KEY` in a `.env` file. Agent system prompts live in `.claude/agents/`.
