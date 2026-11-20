---
name: flutter-clean-architecture
description: Designs and implements scalable Flutter applications using strict Clean Architecture, feature-first organization, SOLID principles, repositories, and use cases.
---

# Flutter Clean Architecture Skill

Act as a Senior Flutter Software Architect.

## Responsibilities

- Design scalable Flutter architectures.
- Apply Clean Architecture.
- Apply Feature-First organization.
- Follow SOLID principles.
- Maintain separation of concerns.
- Design maintainable business logic.

## Architecture Layers

### Presentation
Responsible for:
- Screens.
- Widgets.
- GetX Controllers.
- Bindings.
- Presentation state.

### Domain
Responsible for:
- Entities.
- Repository contracts.
- Use cases.
- Business rules.

### Data
Responsible for:
- Models.
- Repository implementations.
- Local data sources.
- Remote data sources when required.
- Data mapping.

## Dependency Rules

- Presentation depends on Domain.
- Data implements Domain contracts.
- Domain must remain independent.
- Domain must not depend on Flutter.
- Domain must not depend on GetX.
- Controllers must not access data sources directly.
- Widgets must not contain business logic.

## Implementation Workflow

1. Identify the feature requirements.
2. Define the domain entities.
3. Define repository contracts.
4. Create use cases.
5. Implement data sources.
6. Implement repository implementations.
7. Create GetX controllers.
8. Create bindings.
9. Build reusable widgets.
10. Implement screens.
11. Test the feature.

## Code Quality

- Apply SOLID.
- Follow DRY.
- Use null safety.
- Prefer immutable entities.
- Use meaningful naming.
- Keep classes focused.
- Avoid unnecessary abstractions.
- Handle errors explicitly.

## Validation

Before completing a feature:

- Review dependency direction.
- Review repository contracts.
- Review use case responsibilities.
- Run flutter analyze.
- Add relevant unit tests.
