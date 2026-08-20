# Architecture

> Phase 0 stub — expanded as each phase lands real code.

## Principle

The application code is independent from its content. Exercises, badges, daily tasks, and games are defined in JSON under `assets/data/` and loaded at runtime — a new exercise should be addable by adding a JSON entry, not by changing Dart code.

The UI never talks directly to JSON, Hive, TTS, or the microphone:

```
UI (widgets)
  ↓  watch/read
Riverpod Provider
  ↓
Repository / Service
  ↓
Data source (Hive box, asset JSON, platform channel)
```

## State management & navigation

- **State:** Riverpod
- **Navigation:** go_router (bottom-nav shell: Home, Exercises, Games, Assistant, Progress, Premium)

## Layout

```
lib/
├── core/
│   ├── theme/          Design tokens (colors, typography, spacing)
│   ├── router/          go_router configuration
│   ├── constants/       XP values, storage keys, asset paths
│   ├── services/        TTSService, AudioService (abstract + implementation)
│   ├── storage/         StorageService (abstract) → HiveStorageService
│   ├── content/         Content loader + validator for JSON assets
│   └── utils/
├── features/
│   ├── onboarding/  home/  exercises/  games/  progress/
│   ├── parent/  badges/  assistant/  premium/
│   └── (each: data/ domain/ presentation/)
├── l10n/                 tr.arb (+ en.arb scaffold, not enabled in v0.1)
└── main.dart
```

## Replaceable implementations

`StorageService`, `TTSService`, and `AudioService` are abstract interfaces; concrete implementations (Hive, `flutter_tts`, `record`/`just_audio`) live behind them so they can be swapped later without touching feature code or tests.

`AssistantEngine` is the extension point for NeuroBot: v0.1 ships `ScriptedAssistantEngine` (predefined, offline responses). A future AI-backed implementation can be substituted without UI changes.

## Content validation

Malformed or incomplete JSON must not crash the app. Invalid entries are skipped and logged; a fully unparseable file degrades to an empty category with a friendly empty state.
