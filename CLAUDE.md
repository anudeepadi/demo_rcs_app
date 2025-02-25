# RCS Demo App Development Guide

## Build Commands
- Run app: `flutter run`
- Run specific device: `flutter run -d [device_id]`
- Build app: `flutter build apk` (Android) or `flutter build ios` (iOS)
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`

## Testing
- Run all tests: `flutter test`
- Run single test: `flutter test test/widget_test.dart`
- Test with coverage: `flutter test --coverage`

## Linting
- Analyze code: `flutter analyze`
- Format code: `dart format lib/`

## Code Style Guidelines
- **Imports**: Order by 1) Dart SDK, 2) Flutter packages, 3) Third-party packages, 4) Project imports
- **Formatting**: Follow dart format guidelines with 2-space indentation
- **Types**: Always use strong typing; avoid `dynamic` and `var` where possible
- **Naming**: camelCase for variables/methods, PascalCase for classes, snake_case for files
- **Error Handling**: Use try/catch with specific exceptions; avoid swallowing errors
- **State Management**: Use Provider pattern consistently
- **Comments**: Add documentation for public APIs and complex logic
- **Widget Structure**: Extract reusable widgets; keep build methods clean and focused