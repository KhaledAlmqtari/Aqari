import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/pin_controller.dart';

/// PinScreen displays the primary owner authentication gate with:
/// - Field 1: User / Owner Name
/// - Field 2: 4-digit PIN security code
/// - Action Button: Register & Enter System -> takes user directly to HomeScreen.
class PinScreen extends GetView<PinController> {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding Logo
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.darkCardGradient
                          : AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'app_name'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'portfolio_summary'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Modern Card containing the 2 Fields
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Owner Name Field
                          CustomTextField(
                            controller: controller.nameController,
                            label: 'owner_name'.tr,
                            hint: 'enter_name'.tr,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 18),

                          // 2. 4-Digit PIN Field
                          Obx(
                            () => CustomTextField(
                              controller: controller.pinController,
                              label: 'pin_4_digits'.tr,
                              hint: 'pin_4_hint'.tr,
                              prefixIcon: Icons.lock_outline,
                              obscureText: controller.obscurePin.value,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePin.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: controller.toggleObscure,
                              ),
                            ),
                          ),

                          // Error Message Display
                          Obx(() {
                            if (controller.errorMessage.value.isEmpty) {
                              return const SizedBox(height: 12);
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 16, color: AppColors.error),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 14),

                          // Action Button: Register & Enter
                          Obx(
                            () => CustomButton(
                              text: controller.isRegistered.value
                                  ? 'login_enter'.tr
                                  : 'register_enter'.tr,
                              icon: Icons.login_rounded,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.submit,
                              height: 52,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Language Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Get.updateLocale(const Locale('ar')),
                        child: Text(
                          'العربية',
                          style: TextStyle(
                            fontWeight: Get.locale?.languageCode == 'ar'
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: Get.locale?.languageCode == 'ar'
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                      const Text('•'),
                      TextButton(
                        onPressed: () => Get.updateLocale(const Locale('en')),
                        child: Text(
                          'English',
                          style: TextStyle(
                            fontWeight: Get.locale?.languageCode == 'en'
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: Get.locale?.languageCode == 'en'
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
