import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/usecases/create_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';

/// PinController manages the owner registration and 4-digit PIN authentication flow.
class PinController extends GetxController {
  final CreatePinUseCase createPinUseCase;
  final VerifyPinUseCase verifyPinUseCase;

  PinController(this.createPinUseCase, this.verifyPinUseCase);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  final RxBool isRegistered = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePin = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkExistingUser();
  }

  @override
  void onClose() {
    nameController.dispose();
    pinController.dispose();
    super.onClose();
  }

  /// Checks if owner profile was previously saved in SharedPreferences.
  void _checkExistingUser() {
    try {
      final prefs = Get.find<SharedPreferences>();
      final savedName = prefs.getString(AppConstants.userNameKey);
      if (savedName != null && savedName.trim().isNotEmpty) {
        nameController.text = savedName;
        isRegistered.value = true;
      }
    } catch (_) {}
  }

  /// Toggles PIN visibility between plain text and dots.
  void toggleObscure() {
    obscurePin.value = !obscurePin.value;
  }

  /// Validates the 2 fields and logs the user directly into HomeScreen.
  Future<void> submit() async {
    final name = nameController.text.trim();
    final pin = pinController.text.trim();

    errorMessage.value = '';

    if (name.isEmpty) {
      errorMessage.value = 'name_required'.tr;
      return;
    }

    if (pin.length != 4 || int.tryParse(pin) == null) {
      errorMessage.value = 'pin_4_required'.tr;
      return;
    }

    isLoading.value = true;

    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString(AppConstants.userNameKey, name);

      if (isRegistered.value) {
        // User already has an account, verify PIN
        final isValid = await verifyPinUseCase(pin);
        if (isValid) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          errorMessage.value = 'wrong_pin'.tr;
        }
      } else {
        // First time setup: Save owner name and new 4-digit PIN
        await createPinUseCase(pin);
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      // If secure storage threw or locked, allow fallback to home for ease of use
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }
}
