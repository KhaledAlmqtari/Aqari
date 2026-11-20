# Application Security Rules

## PIN Authentication

- Never store PIN values in plain text.
- Never log PIN values.
- Never hardcode authentication credentials.
- Use salted password hashing.
- Use a suitable password-based key derivation function.
- Store sensitive credential material using secure storage.
- Apply failed-attempt limits.
- Apply temporary lockout.
- Protect authenticated routes.
- Handle secure storage errors.

## Storage

- Use SharedPreferences or GetStorage only for non-sensitive preferences.
- Use flutter_secure_storage for sensitive credential material.
- Do not store authentication secrets in ordinary application settings.

## Development

- Never implement an authentication bypass.
- Never expose sensitive information in debug logs.
- Never claim security guarantees without appropriate implementation and testing.
- Document security-related assumptions.
