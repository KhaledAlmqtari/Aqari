# Flutter Starter

A Flutter starter application using GetX and Clean Architecture.

## Features

- GetX state management.
- GetX dependency injection.
- Named routes.
- Clean Architecture.
- PIN setup and verification.
- PBKDF2-HMAC-SHA256 PIN hashing.
- Secure credential storage.
- Failed-attempt lockout.
- Light theme.
- Dark theme.
- System theme.
- Arabic and English localization.
- RTL and LTR support.

## Requirements

- Flutter SDK.
- Dart SDK.
- Android Studio or VS Code.

## Installation

```bash
flutter pub get
flutter run
```

## Architecture

```text
lib/
  core/
  routes/
  features/
    splash/
    pin/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
  main.dart
```

## PIN Security

The application derives a PIN hash using PBKDF2-HMAC-SHA256 and a random salt.

The credential is stored using flutter_secure_storage.

Five failed attempts trigger a temporary 30-second lockout.

This is a local application lock, not a replacement for device-level authentication or a server-side authentication system.

## Development

```bash
dart format lib
flutter analyze
flutter test
```

## Important

Review platform-specific secure storage configuration before production deployment.
Add secure backup, device compromise considerations, and appropriate platform security testing before releasing a production security-sensitive application.
