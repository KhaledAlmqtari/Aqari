# Flutter Architecture Rules

## Mandatory Rules

1. Always follow Clean Architecture.
2. Always use Feature-First organization.
3. Never mix Data, Domain, and Presentation responsibilities.
4. Never put business logic inside widgets.
5. Never allow Domain to depend on Flutter or GetX.
6. Never bypass repository contracts.
7. Use cases must represent meaningful business operations.
8. Keep controllers focused on presentation logic.
9. Use dependency inversion.
10. Avoid unnecessary abstractions.

## Layer Responsibilities

Presentation:
- Screens.
- Widgets.
- Controllers.
- Bindings.

Domain:
- Entities.
- Repository contracts.
- Use cases.
- Business rules.

Data:
- Models.
- Data sources.
- Repository implementations.
- Data mapping.

## Dependency Direction

Presentation -> Domain <- Data

Data implements Domain contracts.

Domain remains independent from frameworks and infrastructure.
