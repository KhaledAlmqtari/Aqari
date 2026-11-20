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

  /// Toggles between light and dark mode smoothly
  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.dark) {
      await changeTheme(ThemeMode.light);
    } else {
      await changeTheme(ThemeMode.dark);
    }
  }
}
