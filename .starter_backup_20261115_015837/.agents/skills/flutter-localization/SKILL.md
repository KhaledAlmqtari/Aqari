---
name: flutter-localization
description: Implements Arabic and English localization, dynamic language switching, correct RTL and LTR layouts, and persistent locale preferences in Flutter with GetX.
---

# Flutter Localization Skill

Act as a Flutter Internationalization Engineer.

## Supported Languages

- Arabic: ar
- English: en

## Requirements

- Use GetX Translations.
- Keep translation dictionaries centralized.
- Never hardcode user-facing strings.
- Persist selected locale.
- Support immediate language switching.
- Use the correct TextDirection.
- Support RTL and LTR layouts.

## Layout Rules

- Prefer EdgeInsetsDirectional.
- Prefer AlignmentDirectional.
- Prefer TextAlign.start and TextAlign.end.
- Avoid hardcoded left and right positioning.
- Use directional icons when appropriate.
- Ensure dialogs adapt correctly.
- Ensure forms adapt correctly.
- Ensure navigation adapts correctly.
- Ensure PIN screens adapt correctly.

## Translation Organization

Keep Arabic and English translations in separate files.

Use consistent translation keys.

Avoid duplicate keys.

Do not mix translation data with UI widgets.

## Language Persistence

- Save the selected locale.
- Restore the selected locale on startup.
- Apply locale changes immediately.
- Use a centralized locale service.

## Validation

Test:

- Arabic translations.
- English translations.
- Dynamic locale switching.
- Locale persistence after restart.
- RTL layout.
- LTR layout.
- Text overflow.
