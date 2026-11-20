# ============================================================
# FLUTTER STARTER APPLICATION GENERATOR
# GetX + Clean Architecture + PIN + Localization + Themes
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host "`nFLUTTER STARTER GENERATOR" -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    throw "No pubspec.yaml found. Run this script inside an existing Flutter project."
}

# ------------------------------------------------------------
# BACKUP AND FILE GENERATION
# ------------------------------------------------------------

$backupRoot = ".starter_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$files = @{}

function Add-ProjectFile {
    param(
        [string]$Path,
        [string]$Content
    )
    $script:files[$Path] = $Content
}

# ============================================================
# PUBSPEC
# ============================================================

Add-ProjectFile "pubspec.yaml" @'
name: flutter_starter
description: Flutter starter using GetX and Clean Architecture.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  get: ^4.7.2
  shared_preferences: ^2.5.3
  flutter_secure_storage: ^9.2.4
  cryptography: ^2.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
'@

# ============================================================
# CORE: CONSTANTS
# ============================================================

Add-ProjectFile "lib/core/constants/app_constants.dart" @'
class AppConstants {
  AppConstants._();

  static const String appName = 'Flutter Starter';
  static const int pinLength = 6;
  static const String defaultLanguage = 'en';

  static const String pinKey = 'pin_credential';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';

  static const String appLocked = 'app_locked';
}
'@

# ============================================================
# CORE: THEME
# ============================================================

Add-ProjectFile "lib/core/theme/app_colors.dart" @'
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFF625B71);
  static const Color error = Color(0xFFB3261E);

  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color darkBackground = Color(0xFF141218);
}
'@

Add-ProjectFile "lib/core/theme/app_theme.dart" @'
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
'@

Add-ProjectFile "lib/core/theme/theme_controller.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeController extends GetxController {
  final SharedPreferences preferences;

  ThemeController(this.preferences);

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  Future<void> init() async {
    final saved = preferences.getString(AppConstants.themeKey);

    themeMode.value = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    Get.changeThemeMode(themeMode.value);
  }

  Future<void> changeTheme(ThemeMode mode) async {
    themeMode.value = mode;

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await preferences.setString(AppConstants.themeKey, value);
    Get.changeThemeMode(mode);
  }
}
'@

# ============================================================
# CORE: LOCALIZATION
# ============================================================

Add-ProjectFile "lib/core/locale/app_translations.dart" @'
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'app_name': 'Flutter Starter',
      'welcome': 'Welcome',
      'home': 'Home',
      'create_pin': 'Create your PIN',
      'confirm_pin': 'Confirm your PIN',
      'enter_pin': 'Enter your PIN',
      'pin_subtitle': 'Enter your six-digit security code',
      'pin_mismatch': 'PIN codes do not match',
      'wrong_pin': 'Incorrect PIN. Try again.',
      'settings': 'Settings',
      'theme': 'Appearance',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'arabic': 'Arabic',
      'english': 'English',
      'lock_app': 'Lock application',
      'pin_created': 'PIN created successfully',
      'continue': 'Continue',
      'delete': 'Delete',
      'loading': 'Please wait...',
      'invalid_pin': 'Please enter all six digits',
      'cancel': 'Cancel',
    },
    'ar': {
      'app_name': 'تطبيق Flutter',
      'welcome': 'مرحباً بك',
      'home': 'الرئيسية',
      'create_pin': 'إنشاء رمز PIN',
      'confirm_pin': 'تأكيد رمز PIN',
      'enter_pin': 'أدخل رمز PIN',
      'pin_subtitle': 'أدخل رمز الأمان المكون من ستة أرقام',
      'pin_mismatch': 'رمزا PIN غير متطابقين',
      'wrong_pin': 'رمز PIN غير صحيح، حاول مرة أخرى',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'حسب النظام',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'lock_app': 'قفل التطبيق',
      'pin_created': 'تم إنشاء رمز PIN بنجاح',
      'continue': 'متابعة',
      'delete': 'حذف',
      'loading': 'يرجى الانتظار...',
      'invalid_pin': 'يرجى إدخال الأرقام الستة',
      'cancel': 'إلغاء',
    },
  };
}
'@

Add-ProjectFile "lib/core/locale/locale_controller.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocaleController extends GetxController {
  final SharedPreferences preferences;

  LocaleController(this.preferences);

  final Rx<Locale> locale = const Locale('en').obs;

  Future<void> init() async {
    final code = preferences.getString(AppConstants.languageKey) ??
        AppConstants.defaultLanguage;

    locale.value = Locale(code);
    Get.updateLocale(locale.value);
  }

  Future<void> changeLanguage(String code) async {
    locale.value = Locale(code);
    await preferences.setString(AppConstants.languageKey, code);
    Get.updateLocale(locale.value);
  }
}
'@

# ============================================================
# PIN DOMAIN
# ============================================================

Add-ProjectFile "lib/features/pin/domain/entities/pin_credential.dart" @'
class PinCredential {
  final String salt;
  final String hash;

  const PinCredential({
    required this.salt,
    required this.hash,
  });
}
'@

Add-ProjectFile "lib/features/pin/domain/repositories/pin_repository.dart" @'
abstract class PinRepository {
  Future<bool> hasPin();
  Future<void> createPin(String pin);
  Future<bool> verifyPin(String pin);
}
'@

Add-ProjectFile "lib/features/pin/domain/usecases/has_pin_usecase.dart" @'
import '../repositories/pin_repository.dart';

class HasPinUseCase {
  final PinRepository repository;

  HasPinUseCase(this.repository);

  Future<bool> call() => repository.hasPin();
}
'@

Add-ProjectFile "lib/features/pin/domain/usecases/create_pin_usecase.dart" @'
import '../repositories/pin_repository.dart';

class CreatePinUseCase {
  final PinRepository repository;

  CreatePinUseCase(this.repository);

  Future<void> call(String pin) => repository.createPin(pin);
}
'@

Add-ProjectFile "lib/features/pin/domain/usecases/verify_pin_usecase.dart" @'
import '../repositories/pin_repository.dart';

class VerifyPinUseCase {
  final PinRepository repository;

  VerifyPinUseCase(this.repository);

  Future<bool> call(String pin) => repository.verifyPin(pin);
}
'@

# ============================================================
# PIN DATA
# ============================================================

Add-ProjectFile "lib/features/pin/data/datasources/pin_local_datasource.dart" @'
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../../domain/entities/pin_credential.dart';

class PinLocalDataSource {
  final FlutterSecureStorage storage;

  PinLocalDataSource(this.storage);

  static const _key = 'pin_credential';
  static const _attemptKey = 'pin_failed_attempts';
  static const _lockKey = 'pin_lock_until';

  final _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Future<String> _derive(String pin, List<int> salt) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    return base64Encode(await key.extractBytes());
  }

  Future<bool> hasPin() async {
    return await storage.read(key: _key) != null;
  }

  Future<void> createPin(String pin) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));

    final hash = await _derive(pin, salt);

    final credential = PinCredential(
      salt: base64Encode(salt),
      hash: hash,
    );

    await storage.write(
      key: _key,
      value: jsonEncode({
        'salt': credential.salt,
        'hash': credential.hash,
      }),
    );

    await storage.delete(key: _attemptKey);
    await storage.delete(key: _lockKey);
  }

  Future<bool> verifyPin(String pin) async {
    final lockUntil = int.tryParse(
      await storage.read(key: _lockKey) ?? '',
    );

    if (lockUntil != null &&
        DateTime.now().millisecondsSinceEpoch < lockUntil) {
      throw Exception('PIN_LOCKED');
    }

    final raw = await storage.read(key: _key);
    if (raw == null) return false;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final salt = base64Decode(data['salt'] as String);
    final expected = data['hash'] as String;

    final actual = await _derive(pin, salt);

    if (actual == expected) {
      await storage.delete(key: _attemptKey);
      await storage.delete(key: _lockKey);
      return true;
    }

    final attempts = int.tryParse(
      await storage.read(key: _attemptKey) ?? '0',
    ) ?? 0;

    final nextAttempts = attempts + 1;

    await storage.write(
      key: _attemptKey,
      value: nextAttempts.toString(),
    );

    if (nextAttempts >= 5) {
      final until = DateTime.now()
          .add(const Duration(seconds: 30))
          .millisecondsSinceEpoch;

      await storage.write(
        key: _lockKey,
        value: until.toString(),
      );

      await storage.write(key: _attemptKey, value: '0');
    }

    return false;
  }
}
'@

Add-ProjectFile "lib/features/pin/data/repositories/pin_repository_impl.dart" @'
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_datasource.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalDataSource dataSource;

  PinRepositoryImpl(this.dataSource);

  @override
  Future<bool> hasPin() => dataSource.hasPin();

  @override
  Future<void> createPin(String pin) => dataSource.createPin(pin);

  @override
  Future<bool> verifyPin(String pin) => dataSource.verifyPin(pin);
}
'@

# ============================================================
# PIN PRESENTATION
# ============================================================

Add-ProjectFile "lib/features/pin/presentation/bindings/pin_binding.dart" @'
import 'package:get/get.dart';
import '../../data/datasources/pin_local_datasource.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/create_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../presentation/controllers/pin_controller.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PinLocalDataSource>()) {
      Get.lazyPut<PinLocalDataSource>(
        () => PinLocalDataSource(Get.find()),
      );
    }

    if (!Get.isRegistered<PinRepository>()) {
      Get.lazyPut<PinRepository>(
        () => PinRepositoryImpl(Get.find()),
      );
    }

    Get.lazyPut(() => CreatePinUseCase(Get.find()));
    Get.lazyPut(() => VerifyPinUseCase(Get.find()));
    Get.lazyPut(() => PinController(
      Get.find(),
      Get.find(),
    ));
  }
}
'@

Add-ProjectFile "lib/features/pin/presentation/controllers/pin_controller.dart" @'
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/create_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';

enum PinMode { setup, confirm, verify }

class PinController extends GetxController {
  final CreatePinUseCase createPin;
  final VerifyPinUseCase verifyPin;

  PinController(this.createPin, this.verifyPin);

  final digits = ''.obs;
  final loading = false.obs;
  final message = ''.obs;

  late PinMode mode;
  String? firstPin;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    mode = switch (args is Map ? args['mode'] : null) {
      'confirm' => PinMode.confirm,
      'verify' => PinMode.verify,
      _ => PinMode.setup,
    };

    if (args is Map && args['pin'] is String) {
      firstPin = args['pin'] as String;
    }
  }

  String get title => switch (mode) {
    PinMode.setup => 'create_pin'.tr,
    PinMode.confirm => 'confirm_pin'.tr,
    PinMode.verify => 'enter_pin'.tr,
  };

  void addDigit(String value) {
    if (loading.value || digits.value.length >= AppConstants.pinLength) {
      return;
    }

    message.value = '';
    digits.value += value;

    if (digits.value.length == AppConstants.pinLength) {
      submit();
    }
  }

  void removeDigit() {
    if (loading.value || digits.isEmpty) return;

    digits.value = digits.value.substring(0, digits.value.length - 1);
    message.value = '';
  }

  Future<void> submit() async {
    if (digits.value.length != AppConstants.pinLength || loading.value) {
      message.value = 'invalid_pin'.tr;
      return;
    }

    final entered = digits.value;
    loading.value = true;

    try {
      switch (mode) {
        case PinMode.setup:
          Get.offNamed(
            '/pin',
            arguments: {
              'mode': 'confirm',
              'pin': entered,
            },
          );
          break;

        case PinMode.confirm:
          if (entered != firstPin) {
            message.value = 'pin_mismatch'.tr;
            digits.value = '';
            break;
          }

          await createPin(entered);
          Get.offAllNamed('/home');
          Get.snackbar('app_name'.tr, 'pin_created'.tr);
          break;

        case PinMode.verify:
          final success = await verifyPin(entered);

          if (success) {
            Get.offAllNamed('/home');
          } else {
            message.value = 'wrong_pin'.tr;
            digits.value = '';
          }
          break;
      }
    } catch (e) {
      digits.value = '';
      message.value = e.toString().contains('PIN_LOCKED')
          ? 'PIN temporarily locked. Wait 30 seconds.'
          : 'Authentication failed. Please try again.';
    } finally {
      loading.value = false;
    }
  }
}
'@

Add-ProjectFile "lib/features/pin/presentation/screens/pin_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pin_controller.dart';

class PinScreen extends GetView<PinController> {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(Icons.lock_outline, size: 56),
                  const SizedBox(height: 24),
                  Obx(() => Text(
                    controller.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  )),
                  const SizedBox(height: 10),
                  Text('pin_subtitle'.tr),
                  const SizedBox(height: 30),

                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final filled = index < controller.digits.value.length;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 9),
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  )),

                  const SizedBox(height: 22),

                  Obx(() => Text(
                    controller.message.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  )),

                  const Spacer(),

                  ...List.generate(3, (row) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (column) {
                        final number = row * 3 + column + 1;
                        return _key(number.toString());
                      }),
                    );
                  }),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 75),
                      _key('0'),
                      IconButton(
                        onPressed: controller.removeDigit,
                        icon: const Icon(Icons.backspace_outlined),
                      ),
                    ],
                  ),

                  const Spacer(),
                  Obx(() => controller.loading.value
                      ? const CircularProgressIndicator()
                      : const SizedBox(height: 4)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _key(String number) {
    return SizedBox(
      width: 75,
      height: 65,
      child: TextButton(
        onPressed: () => controller.addDigit(number),
        child: Text(
          number,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
'@

# ============================================================
# SPLASH FEATURE
# ============================================================

Add-ProjectFile "lib/features/splash/presentation/controllers/splash_controller.dart" @'
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../pin/domain/usecases/has_pin_usecase.dart';

class SplashController extends GetxController {
  final HasPinUseCase hasPin;

  SplashController(this.hasPin);

  @override
  void onReady() {
    super.onReady();
    initialize();
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final exists = await hasPin();

    Get.offNamed(
      '/pin',
      arguments: {
        'mode': exists ? 'verify' : 'setup',
      },
    );
  }
}
'@

Add-ProjectFile "lib/features/splash/presentation/bindings/splash_binding.dart" @'
import 'package:get/get.dart';
import '../../../pin/data/datasources/pin_local_datasource.dart';
import '../../../pin/data/repositories/pin_repository_impl.dart';
import '../../../pin/domain/repositories/pin_repository.dart';
import '../../../pin/domain/usecases/has_pin_usecase.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PinLocalDataSource>()) {
      Get.lazyPut(() => PinLocalDataSource(Get.find()));
    }

    if (!Get.isRegistered<PinRepository>()) {
      Get.lazyPut<PinRepository>(
        () => PinRepositoryImpl(Get.find()),
      );
    }

    Get.lazyPut(() => HasPinUseCase(Get.find()));
    Get.lazyPut(() => SplashController(Get.find()));
  }
}
'@

Add-ProjectFile "lib/features/splash/presentation/screens/splash_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 85,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'app_name'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
'@

# ============================================================
# HOME FEATURE
# ============================================================

Add-ProjectFile "lib/features/home/presentation/bindings/home_binding.dart" @'
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
'@

Add-ProjectFile "lib/features/home/presentation/controllers/home_controller.dart" @'
import 'package:get/get.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/locale/locale_controller.dart';

class HomeController extends GetxController {
  ThemeController get themeController => Get.find();
  LocaleController get localeController => Get.find();

  Future<void> lockApplication() async {
    Get.offAllNamed(
      '/pin',
      arguments: {'mode': 'verify'},
    );
  }

  Future<void> setLanguage(String code) {
    return localeController.changeLanguage(code);
  }
}
'@

Add-ProjectFile "lib/features/home/presentation/screens/home_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/locale/locale_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final locale = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
        actions: [
          IconButton(
            onPressed: controller.lockApplication,
            tooltip: 'lock_app'.tr,
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.waving_hand_outlined,
              size: 65,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'welcome'.tr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 35),

            Text(
              'settings'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('theme'.tr),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButton<ThemeMode>(
                      isExpanded: true,
                      value: theme.themeMode.value,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('light'.tr),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('dark'.tr),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('system'.tr),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          theme.changeTheme(value);
                        }
                      },
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('language'.tr),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButton<String>(
                      isExpanded: true,
                      value: locale.locale.value.languageCode,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('english'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text('arabic'.tr),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setLanguage(value);
                        }
                      },
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            OutlinedButton.icon(
              onPressed: controller.lockApplication,
              icon: const Icon(Icons.lock),
              label: Text('lock_app'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
'@

# ============================================================
# ROUTES
# ============================================================

Add-ProjectFile "lib/routes/app_routes.dart" @'
abstract class AppRoutes {
  static const splash = '/';
  static const pin = '/pin';
  static const home = '/home';
}
'@

Add-ProjectFile "lib/routes/app_pages.dart" @'
import 'package:get/get.dart';

import '../features/splash/presentation/bindings/splash_binding.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

import '../features/pin/presentation/bindings/pin_binding.dart';
import '../features/pin/presentation/screens/pin_screen.dart';

import '../features/home/presentation/bindings/home_binding.dart';
import '../features/home/presentation/screens/home_screen.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.pin,
      page: () => const PinScreen(),
      binding: PinBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}
'@

# ============================================================
# MAIN APPLICATION
# ============================================================

Add-ProjectFile "lib/main.dart" @'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/locale/app_translations.dart';
import 'core/locale/locale_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

import 'features/pin/data/datasources/pin_local_datasource.dart';
import 'features/pin/data/repositories/pin_repository_impl.dart';
import 'features/pin/domain/repositories/pin_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  Get.put<SharedPreferences>(preferences, permanent: true);
  Get.put<FlutterSecureStorage>(secureStorage, permanent: true);

  Get.put<PinLocalDataSource>(
    PinLocalDataSource(secureStorage),
    permanent: true,
  );

  Get.put<PinRepository>(
    PinRepositoryImpl(Get.find<PinLocalDataSource>()),
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
      title: 'Flutter Starter',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode.value,
      locale: locale.locale.value,
      fallbackLocale: const Locale('en'),
      translations: AppTranslations(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
'@

# ============================================================
# README
# ============================================================

Add-ProjectFile "README.md" @'
# Flutter Starter

A Flutter starter application using GetX and Clean Architecture.

## Features

- GetX state management.
- GetX dependency injection.
- Named routes.
- Clean Architecture.
- PIN setup and verification.
- PBKDF2-HMAC-SHA256 PIN hashing.
- Secure credential storage.
- Failed-attempt lockout.
- Light theme.
- Dark theme.
- System theme.
- Arabic and English localization.
- RTL and LTR support.

## Requirements

- Flutter SDK.
- Dart SDK.
- Android Studio or VS Code.

## Installation

```bash
flutter pub get
flutter run
```

## Architecture

```text
lib/
  core/
  routes/
  features/
    splash/
    pin/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
  main.dart
```

## PIN Security

The application derives a PIN hash using PBKDF2-HMAC-SHA256 and a random salt.

The credential is stored using flutter_secure_storage.

Five failed attempts trigger a temporary 30-second lockout.

This is a local application lock, not a replacement for device-level authentication or a server-side authentication system.

## Development

```bash
dart format lib
flutter analyze
flutter test
```

## Important

Review platform-specific secure storage configuration before production deployment.
Add secure backup, device compromise considerations, and appropriate platform security testing before releasing a production security-sensitive application.
'@

# ============================================================
# ANTIGRAVITY SKILLS
# ============================================================

Add-ProjectFile ".agents/skills/flutter-clean-architecture/SKILL.md" @'
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
'@

Add-ProjectFile ".agents/skills/getx-development/SKILL.md" @'
---
name: getx-development
description: Implements GetX controllers, reactive state, dependency injection, bindings, routing, and lifecycle management.
---

# GetX Development

- Use GetxController for presentation state.
- Use Rx only when required.
- Use Obx for reactive UI.
- Use Bindings for dependency injection.
- Use GetMaterialApp.
- Use centralized named routes.
- Attach bindings to routes.
- Avoid direct storage access in controllers.
- Keep business rules in Domain.
- Respect onInit, onReady, and onClose.
- Test controller behavior.
'@

Add-ProjectFile ".agents/skills/flutter-ui-ux/SKILL.md" @'
---
name: flutter-ui-ux
description: Designs responsive Material 3 Flutter interfaces with reusable widgets, accessible colors, and light and dark themes.
---

# Flutter UI/UX

- Use Material Design 3.
- Centralize colors and typography.
- Support Light, Dark, and System themes.
- Avoid hardcoded colors.
- Build reusable widgets.
- Support small and large screens.
- Handle keyboard and safe areas.
- Prevent overflow.
- Provide loading, error, empty, and validation states.
- Maintain accessible contrast.
'@

Add-ProjectFile ".agents/skills/flutter-localization/SKILL.md" @'
---
name: flutter-localization
description: Implements Arabic and English localization, persistent locale selection, and correct RTL/LTR Flutter layouts.
---

# Flutter Localization

- Support Arabic and English.
- Use GetX translations.
- Never hardcode user-facing text.
- Persist locale selection.
- Apply changes immediately.
- Use EdgeInsetsDirectional.
- Use AlignmentDirectional.
- Use TextAlign.start and TextAlign.end.
- Check directional icons.
- Test RTL and LTR on every feature.
'@

Add-ProjectFile ".agents/skills/flutter-pin-security/SKILL.md" @'
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
'@

# ============================================================
# ANTIGRAVITY RULES
# ============================================================

Add-ProjectFile ".agents/rules/flutter_architecture.md" @'
# Architecture Rules

- Always follow Clean Architecture.
- Use Feature-First organization.
- Keep Data, Domain, and Presentation separate.
- Domain must not depend on Flutter or GetX.
- Use repository contracts.
- Use use cases for business operations.
- Controllers must not access storage directly.
- Avoid business logic in widgets.
- Apply SOLID and DRY.
'@

Add-ProjectFile ".agents/rules/getx_rules.md" @'
# GetX Rules

- Use GetX for state management.
- Use Bindings for dependency injection.
- Use GetMaterialApp.
- Define routes centrally.
- Use GetPage.
- Avoid duplicate registrations.
- Respect controller lifecycle.
- Do not put business rules in controllers.
- Do not access data sources directly from controllers.
'@

Add-ProjectFile ".agents/rules/security_rules.md" @'
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
'@

Add-ProjectFile ".agents/rules/ui_localization_rules.md" @'
# UI and Localization Rules

- Use Material Design 3.
- Support Light, Dark, and System themes.
- Support Arabic and English.
- Support RTL and LTR.
- Centralize colors and typography.
- Never hardcode user-facing strings.
- Use EdgeInsetsDirectional.
- Use AlignmentDirectional.
- Use TextAlign.start and TextAlign.end.
- Prevent overflow.
- Verify every screen in both languages and themes.
'@

# ============================================================
# ROOT AGENT INSTRUCTIONS
# ============================================================

Add-ProjectFile "AGENTS.md" @'
# Flutter Starter - Agent Instructions

You are a Senior Flutter Engineer and Software Architect.

## Technology

- Flutter.
- Dart.
- GetX.
- Clean Architecture.
- Material Design 3.

## Application Requirements

- Splash screen.
- PIN setup.
- PIN confirmation.
- PIN verification.
- Secure local PIN storage.
- Home screen.
- Light theme.
- Dark theme.
- System theme.
- Arabic localization.
- English localization.
- RTL and LTR.

## Architecture

Presentation -> Domain <- Data

Use GetX for state management, dependency injection, routing, and localization.

## Development Workflow

1. Inspect the existing project.
2. Read all applicable Skills and Rules.
3. Inspect pubspec.yaml.
4. Implement core services.
5. Implement Splash.
6. Implement PIN authentication.
7. Implement Home.
8. Add tests.
9. Run dart format.
10. Run flutter analyze.
11. Run flutter test.

## Rules

- Never overwrite existing files without inspecting them.
- Never bypass Clean Architecture.
- Never store raw PIN values.
- Never hardcode user-facing strings.
- Never claim tests passed without executing them.
- Implement actual functionality, not mockups.
- Document significant decisions.

## Skills

Use the relevant skill in .agents/skills/ for each task.

## Final Report

Report:
- Implemented features.
- Files created and modified.
- Dependencies.
- Tests executed.
- Known limitations.
- Commands to run the application.
'@

# ============================================================
# FILE WRITING WITH BACKUP
# ============================================================

$created = 0
$updated = 0

foreach ($path in $files.Keys) {

    $parent = Split-Path -Parent $path

    if ($parent -and !(Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force |
            Out-Null
    }

    if (Test-Path $path) {

        $backupPath = Join-Path $backupRoot $path
        $backupParent = Split-Path -Parent $backupPath

        New-Item -ItemType Directory -Path $backupParent -Force |
            Out-Null

        Copy-Item -Path $path -Destination $backupPath -Force

        Set-Content -Path $path -Value $files[$path] -Encoding UTF8

        Write-Host "[UPDATED] $path" -ForegroundColor Yellow
        $updated++

    }
    else {

        Set-Content -Path $path -Value $files[$path] -Encoding UTF8

        Write-Host "[CREATED] $path" -ForegroundColor Green
        $created++

    }
}

# ============================================================
# FLUTTER DEPENDENCIES
# ============================================================

Write-Host "`nInstalling Flutter dependencies..." -ForegroundColor Cyan

flutter pub get

if ($LASTEXITCODE -ne 0) {
    throw "flutter pub get failed. Check Flutter and dependency compatibility."
}

# ============================================================
# FORMATTING
# ============================================================

Write-Host "`nFormatting Dart files..." -ForegroundColor Cyan

dart format lib

# ============================================================
# FINAL REPORT
# ============================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " FLUTTER STARTER CREATED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "Files created : $created"
Write-Host "Files updated : $updated"

if ($updated -gt 0) {
    Write-Host "Backups saved in: $backupRoot" -ForegroundColor Yellow
}

Write-Host "`nNext commands:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter test"
Write-Host "flutter run"

Write-Host "`nOpen the project in Antigravity to continue development." -ForegroundColor Green
