# VoCa Builder

A vocabulary learning app built in Flutter for Android, iOS, and web. Capture words into your personal WordBase, then reinforce them through crossword puzzles and spaced repetition.

Backend: AWS Amplify (AppSync GraphQL + DynamoDB + Cognito).

## Features

- **Word Capture** — add words with definitions, crossword clues, and associations
- **Crossword Puzzle** — play a crossword built from your WordBase
- **Spaced Repetition** — coming soon

## Getting Started

### Prerequisites

- Flutter 3.41.6 / Dart 3.11.4
- An AWS Amplify backend (see below)

### Setup

1. Clone the repo
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Copy your Amplify config into the project root:
   ```bash
   cp /path/to/amplify_outputs.json .
   ```
   Get this file from the Amplify console — it is gitignored.

4. Run the app:
   ```bash
   flutter run
   ```

## Commands

```bash
# Run on a connected device / emulator
flutter run

# Run tests
flutter test

# Analyze for linting issues
flutter analyze

# Build for Android
flutter build apk

# Build for web
flutter build web
```

## AI Pipeline

`pipeline.py` chains Anthropic API agents (planner → refiner → implementer → reviewer → committer) for autonomous feature implementation.

```bash
python pipeline.py "Your task description here"
```

Requires an `ANTHROPIC_API_KEY` in a `.env` file.

## Architecture

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Android / iOS / Web) |
| Auth | AWS Cognito |
| API | AWS AppSync (GraphQL) |
| Database | DynamoDB |

Navigation is handled by a bottom-nav shell (`MainShell`) with an `IndexedStack` to preserve tab state. Word data lives in an in-memory `WordBase`; Amplify persistence is a planned next step.