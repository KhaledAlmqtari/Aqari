---
name: getx-development
description: Implements Flutter state management, dependency injection, lifecycle management, named routing, bindings, and localization using GetX.
---

# GetX Development Skill

Act as a Senior Flutter GetX Engineer.

## State Management

- Use GetxController for feature state.
- Use Rx variables only for genuinely reactive state.
- Use Obx for reactive UI updates.
- Use GetBuilder when simple state management is more appropriate.
- Avoid unnecessary reactive rebuilds.
- Keep controllers focused.

## Dependency Injection

- Use Bindings for dependency registration.
- Use Get.lazyPut for lazy dependencies.
- Use Get.put when immediate registration is necessary.
- Use Get.find to retrieve registered dependencies.
- Respect dependency lifecycle.
- Avoid duplicate registrations.

## Navigation

- Use GetMaterialApp.
- Define routes centrally.
- Use GetPage for named routes.
- Attach bindings to routes.
- Use appropriate navigation stack management.
- Prevent unauthorized navigation.

## Controller Rules

Controllers must:

- Coordinate presentation state.
- Call use cases.
- Expose UI-friendly state.
- Handle loading states.
- Handle presentation errors.
- Dispose resources when necessary.

Controllers must not:

- Access SharedPreferences directly.
- Access secure storage directly.
- Implement business rules.
- Contain widget construction logic.
- Implement repository logic.

## Lifecycle

- Use onInit for initialization.
- Use onReady when appropriate.
- Use onClose for cleanup.
- Avoid unnecessary controller recreation.

## Validation

- Test controllers independently.
- Verify dependency registration.
- Verify navigation behavior.
- Verify lifecycle cleanup.
