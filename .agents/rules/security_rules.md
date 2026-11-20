# Security Rules

- Never store PIN in plain text.
- Use salted PBKDF2-HMAC-SHA256.
- Use secure random salt.
- Use flutter_secure_storage.
- Implement failed-attempt protection.
- Implement lockout.
- Never hardcode master credentials.
- Never log sensitive data.
- Protect authenticated navigation.
- Document security assumptions.
