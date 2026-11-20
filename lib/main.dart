import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/locale/app_translations.dart';
import 'core/locale/locale_controller.dart';
import 'core/storage/database_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

import 'features/pin/data/datasources/pin_local_datasource.dart';
import 'features/pin/data/repositories/pin_repository_impl.dart';
import 'features/pin/domain/repositories/pin_repository.dart';
import 'features/pin/domain/usecases/has_pin_usecase.dart';
import 'features/pin/domain/usecases/create_pin_usecase.dart';
import 'features/pin/domain/usecases/verify_pin_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final databaseService = DatabaseService();

  Get.put<SharedPreferences>(preferences, permanent: true);
  Get.put<FlutterSecureStorage>(secureStorage, permanent: true);
  Get.put<DatabaseService>(databaseService, permanent: true);

  Get.put<PinLocalDataSource>(
    PinLocalDataSource(secureStorage),
    permanent: true,
  );

  Get.put<PinRepository>(
    PinRepositoryImpl(Get.find<PinLocalDataSource>()),
    permanent: true,
  );

  // <-- تم إضافة تسجيل HasPinUseCase هنا لحل مشكلة توقف SplashController
  Get.put<HasPinUseCase>(
    HasPinUseCase(Get.find<PinRepository>()),
    permanent: true,
  );

  Get.put<CreatePinUseCase>(
    CreatePinUseCase(Get.find<PinRepository>()),
    permanent: true,
  );

  Get.put<VerifyPinUseCase>(
    VerifyPinUseCase(Get.find<PinRepository>()),
    permanent: true,
  );

  final themeController = Get.put(
    ThemeController(preferences),
    permanent: true,
  );

  final localeController = Get.put(
    LocaleController(preferences),
    permanent: true,
  );

  await themeController.init();
  await localeController.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final locale = Get.find<LocaleController>();

    return GetMaterialApp(
      title: 'إدارة الأملاك العقارية',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.pin,
      getPages: AppPages.pages,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode.value,
      locale: locale.locale.value,
      fallbackLocale: const Locale('ar'),
      translations: AppTranslations(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
