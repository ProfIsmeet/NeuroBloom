# Contributing

> Phase 0 stub — the full workflow, with real file paths, lands once the content engine exists (Phase 4).

## Adding a new exercise

1. Add a JSON entry to the relevant file under `assets/data/exercises/` (`tongue.json`, `lips.json`, or `speech.json`), matching the `Exercise` schema (`id`, `category`, `title`, `description`, `instruction`, `duration`, `repetitions`, `tts`, `animation`, `xp`, `difficulty`, `ageRange`, `enabled`).
2. Do not alter the clinical meaning of an existing exercise, and do not invent new clinical content — exercise wording should be reviewable by a qualified speech-language professional.
3. Add an animation asset if available; the runtime falls back gracefully if it's missing.
4. Run `flutter test` to confirm content validation still passes.
5. Run the app and verify the exercise appears (respecting `enabled` and `ageRange`).

## Adding a new badge

Add an entry to `assets/data/badges.json` with its unlock condition; no Dart changes should be required for a straightforward stat-threshold badge.

## Adding a new game

Implement a `GameDefinition` and register it with the games repository; content (rounds/targets) is JSON-driven the same way exercises are.

## Adding new JSON content generally

All content lives under `assets/data/`. Invalid or incomplete JSON must never crash the app — the content loader skips bad entries and logs them.

## Adding animations

Drop a Lottie `.json` (or equivalent) into `assets/animations/`; if the referenced asset is missing at runtime, the UI shows a fallback illustration instead of failing.
