---
name: flutter-pin-security
description: Designs secure local PIN authentication, salted password hashing, secure credential storage, verification, rate limiting, and authentication tests in Flutter.
---

# Flutter PIN Security Skill

Act as a Mobile Application Security Engineer.

## Authentication Flow

1. Detect whether PIN setup is complete.
2. Request PIN creation on first launch.
3. Confirm the new PIN.
4. Save a secure credential representation.
5. Request PIN verification on subsequent launches.
6. Grant access only after successful verification.
7. Support application locking.

## Security Requirements

- Never store raw PIN values.
- Never store PIN values in plain text.
- Use cryptographically secure random salts.
- Use a password-based key derivation function such as PBKDF2-HMAC-SHA256 with an appropriate work factor.
- Store the resulting hash and salt securely.
- Use flutter_secure_storage.
- Never log PIN values.
- Never hardcode a master PIN.
- Never implement authentication bypasses.
- Implement configurable failed-attempt limits.
- Implement temporary lockout.
- Use secure comparison where applicable.
- Handle credential storage failures safely.

## Architecture

Domain:
- Authentication entities.
- Repository contracts.
- PIN use cases.
- Authentication business rules.

Data:
- Secure storage data source.
- Cryptographic implementation.
- Repository implementation.

Presentation:
- PIN input.
- Numeric keypad.
- PIN indicators.
- Validation feedback.
- Authentication screens.

## Authentication Rules

- Validate PIN length.
- Require confirmation during initial setup.
- Reject mismatched confirmation.
- Verify the stored credential.
- Track failed attempts.
- Enforce lockout policy.
- Reset failed attempts after successful authentication.
- Do not expose sensitive values through navigation arguments or logs.

## Testing

Test:

- Correct PIN.
- Incorrect PIN.
- PIN confirmation mismatch.
- Invalid PIN length.
- Failed attempts.
- Lockout.
- Credential persistence.
- Application restart.
- Storage failures.
