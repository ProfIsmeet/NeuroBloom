# NeuroBloom

NeuroBloom is a child-friendly, gamified Android app that supports home practice for children with Childhood Apraxia of Speech (CAS) — designed to support, not replace, professional speech therapy.

> **Status: v0.1 in development.** Phases 0–9 (design system, onboarding, home/emotion tracking, exercise engine, exercise runner, XP/streaks/badges, the Harf Çarkı mini-game, progress screen, and the PIN-gated parent dashboard) are complete. Phases 10–13 (premium placeholder, NeuroBot MVP, integration/security QA, and final documentation) are still in progress. See `PHASES.md` for the full roadmap and `ARCHITECTURE.md` for the technical design.

## Installing the shared APK

If you received `app-release.apk` directly (rather than building from source):

1. Copy the APK to your Android phone (e.g. via a messaging app, email, or USB).
2. Tap the file to install it. Android will likely warn that installing apps from outside the Play Store is blocked — go to **Settings → Apps → Special access → Install unknown apps**, choose the app you used to open the file (e.g. your file manager or chat app), and allow it.
3. Open **NeuroBloom** from your app drawer.

No account, sign-in, or internet connection is required — everything works fully offline (see [Privacy & offline model](#privacy--offline-model) below).

**Uninstalling and reinstalling wipes all data** (profile, XP, streaks, badges, the parent PIN) because it's stored only on your device — this is normal Android behavior, not a bug.

## Requirements (for building from source)

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

The output APK is written to `build/app/outputs/flutter-apk/app-release.apk`. This is the file to share with others — it's signed with Flutter's default debug keystore (fine for informal sharing/testing; a dedicated release signing key would be needed before any app store submission).

## Running tests

```bash
flutter analyze
flutter test
```

## Privacy & offline model

NeuroBloom is offline-first: onboarding, exercises, XP/badges/streaks, the Harf Çarkı game, progress tracking, and the parent dashboard all work without an internet connection. No child data leaves the device. Voice recordings made during the Harf Çarkı game are temporary and are deleted at the end of the session — nothing is stored permanently or uploaded. The parent PIN is salted and hashed (PBKDF2-HMAC-SHA256) and kept in Android's secure storage — never in plaintext.

## Clinical disclaimer

NeuroBloom is a support and motivation tool. It does not diagnose, does not perform clinical assessment, and does not evaluate pronunciation correctness. It is intended to complement, not replace, guidance from a qualified speech-language professional.
