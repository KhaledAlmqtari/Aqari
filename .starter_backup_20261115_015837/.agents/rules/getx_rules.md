# GetX Rules

## State Management

- Use GetX for application state management.
- Use GetxController for feature controllers.
- Use Rx only when reactive updates are necessary.
- Avoid unnecessary Obx widgets.
- Keep state management separate from business logic.

## Dependency Injection

- Use Bindings for dependency registration.
- Use Get.lazyPut for lazy registration.
- Use Get.put for immediate registration when necessary.
- Use Get.find to retrieve dependencies.
- Avoid duplicate registrations.
- Respect controller lifecycle.

## Navigation

- Use GetMaterialApp.
- Use centralized named routes.
- Use GetPage.
- Attach the correct bindings.
- Protect authenticated routes.
- Prevent unauthorized Home navigation.

## Controller Rules

- Controllers call use cases.
- Controllers do not access storage directly.
- Controllers do not access data sources.
- Controllers do not contain widget code.
- Controllers do not implement business rules.
- Clean up resources in onClose.
