---
name: flutter-clean-architecture
description: Builds maintainable Flutter applications with strict Clean Architecture, SOLID, repositories, use cases, and feature-first organization.
---

# Flutter Clean Architecture

- Always inspect the existing project.
- Separate Presentation, Domain, and Data.
- Presentation depends on Domain.
- Data implements Domain contracts.
- Domain must not depend on Flutter or GetX.
- Use cases represent business operations.
- Controllers call use cases.
- Repositories own data access abstraction.
- Keep widgets free from business logic.
- Apply SOLID and DRY.
- Test use cases and repositories.
- Run flutter analyze.
