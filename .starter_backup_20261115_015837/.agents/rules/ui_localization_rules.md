# UI and Localization Rules

## UI

- Use Material Design 3.
- Use centralized theme definitions.
- Support Light Theme.
- Support Dark Theme.
- Support System Theme.
- Avoid hardcoded colors.
- Build reusable widgets.
- Maintain consistent spacing.
- Prevent layout overflow.
- Respect SafeArea.
- Support responsive layouts.

## Localization

- Support Arabic and English.
- Use GetX Translations.
- Never hardcode user-facing strings.
- Persist the selected language.
- Apply language changes immediately.
- Support RTL and LTR.

## Directional Layout

Prefer:

- EdgeInsetsDirectional.
- AlignmentDirectional.
- TextAlign.start.
- TextAlign.end.

Avoid unnecessary:

- EdgeInsets.only(left: ...).
- EdgeInsets.only(right: ...).
- Alignment.centerLeft.
- Alignment.centerRight.

Verify every screen in both languages and themes.
