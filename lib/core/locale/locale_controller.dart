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
