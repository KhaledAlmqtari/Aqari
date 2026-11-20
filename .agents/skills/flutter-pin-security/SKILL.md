---
name: flutter-pin-security
description: Implements secure local PIN creation, confirmation, PBKDF2 hashing, secure storage, verification, and lockout.
---

# Flutter PIN Security

- Never store raw PIN values.
- Use cryptographically secure random salts.
- Use PBKDF2-HMAC-SHA256.
- Store credential material using secure storage.
- Implement failed-attempt protection.
- Implement temporary lockout.
- Never hardcode master PINs.
- Never log secrets.
- Keep business rules in Domain.
- Keep cryptography in Data.
- Test successful and failed verification.
