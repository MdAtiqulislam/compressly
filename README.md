# Compressly (compressly)

Media utility app — compress, convert, resize and crop images/videos with before-after comparison.

## Features

- Batch compression queue
- Format converter, resizer and cropper
- Side-by-side comparison view
- Processing history
- Premium upsell, settings and main navigation

## Tech Stack

- Flutter (Dart)
- GetX for state management and routing
- On-device media processing

## Getting Started

```bash
flutter pub get
flutter run
```

Build a release APK:

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── app/modules/   # Home, compressor, converter, batch, history, premium
├── services/      # File/media services
└── main.dart      # App entry point
```

## Notes

- App label: "Compressly" (Android)
- No secrets, keystores or Firebase configs are committed to this repository.
