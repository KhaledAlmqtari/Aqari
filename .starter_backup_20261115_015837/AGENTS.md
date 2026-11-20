# Project Agent Instructions

## Project Identity

Flutter application using:

- Flutter and Dart.
- GetX.
- Clean Architecture.
- Feature-First Architecture.
- Material Design 3.

## Main Requirements

The application must support:

1. Light Theme.
2. Dark Theme.
3. System Theme.
4. Arabic Language.
5. English Language.
6. RTL and LTR.
7. Splash Screen.
8. PIN Setup.
9. PIN Confirmation.
10. PIN Verification.
11. Secure Local Authentication.
12. Home Screen.
13. Persistent Settings.

## Mandatory Architecture

Follow Clean Architecture strictly.

Presentation -> Domain <- Data

Use GetX for:

- State management.
- Dependency injection.
- Named routing.
- Localization.

Do not place business logic inside widgets or controllers.

## Required Project Structure

Preserve the existing lib/ structure.

Extend features using:

- data/
- domain/
- presentation/

Use the existing project structure as the source of truth.

## Development Workflow

PHASE 1: Inspect the existing project.

PHASE 2: Configure dependencies and architecture.

PHASE 3: Implement core services, themes, and localization.

PHASE 4: Implement Splash.

PHASE 5: Implement secure PIN authentication.

PHASE 6: Implement Home.

PHASE 7: Implement tests.

PHASE 8: Run final quality checks.

## Quality Requirements

Before completing:

- Run dart format.
- Run flutter analyze.
- Run flutter test.
- Fix errors.
- Verify RTL and LTR.
- Verify Light and Dark themes.
- Verify PIN security.
- Verify route protection.

Never claim a command succeeded unless it was actually executed successfully.

## Agent Skills

Use the relevant skill when performing its corresponding task.

- flutter-clean-architecture
- getx-development
- flutter-ui-ux
- flutter-localization
- flutter-pin-security

## Agent Rules

All files in .agents/rules/ are mandatory project rules.

Do not ignore or bypass them.

## Important

Inspect existing files before modifying them.

Do not blindly overwrite project configuration.

Do not generate only mockups or static UI.

Implement working application functionality.

Document assumptions and engineering decisions.

At completion, provide an implementation report and instructions for running the application.
