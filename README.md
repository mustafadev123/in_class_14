# Cloud Courier

A Flutter/Firebase Cloud Messaging activity that maps validated cloud data to
visible campus content across foreground, background-tap, and cold-start paths.

## Payload

```json
{
  "notification": {
    "title": "Campus event update",
    "body": "View the latest campus information"
  },
  "data": {
    "action": "update_ui",
    "asset": "promo"
  }
}
```

Supported asset values are `default` and `promo`. Unknown or missing values are
rejected with an on-screen diagnostic while the last valid content remains.

## Verification

Run `flutter analyze`, `flutter test`, and `flutter run` on an Android device
with Google Play services. Live test results and the graduate reflection are in
[`docs/evidence_and_reflection.md`](docs/evidence_and_reflection.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
