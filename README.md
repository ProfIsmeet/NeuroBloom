# NeuroBloom

NeuroBloom is a child-friendly, gamified digital support platform for children practicing exercises related to Childhood Apraxia of Speech (CAS), built to support — not replace — professional speech therapy at home.

> **Status: v0.1 in development.** This README is a Phase 0 stub. It will be completed in Phase 13 with full setup, build, and content-authoring instructions. See `PHASES.md` for the implementation roadmap and `ARCHITECTURE.md` for the technical design.

## Requirements

- Flutter SDK: stable channel (developed against Flutter 3.47.1 / Dart 3.13.1)
- Android SDK: platform 36, build-tools 36.0.0, platform-tools
- JDK 17+
- An Android device (USB debugging enabled) or emulator

## Getting started

```bash
flutter pub get
flutter run
```

## Building a release APK

```bash
flutter build apk --release
```

The output APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Privacy & offline model

NeuroBloom is offline-first: onboarding, exercises, XP/badges/streaks, the Letter Wheel game, progress tracking, the parent dashboard, and NeuroBot all work without an internet connection. No child data leaves the device. Voice recordings made during games are temporary and are deleted at the end of the session — nothing is stored permanently or uploaded.

## Clinical disclaimer

NeuroBloom is a support and motivation tool. It does not diagnose, does not perform clinical assessment, and does not evaluate pronunciation correctness. It is intended to complement, not replace, guidance from a qualified speech-language professional.
