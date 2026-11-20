import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/locale/locale_controller.dart';
import '../controllers/home_controller.dart';

/// SettingsTab provides system configuration for Appearance, Language, Currency, and PIN Security.
class SettingsTab extends StatelessWidget {
  final bool showAppBar;

  const SettingsTab({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final locale = Get.find<LocaleController>();
    final home = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text('settings'.tr),
              actions: [
                IconButton(
                  icon: const Icon(Icons.lock_outline),
                  tooltip: 'lock_app'.tr,
                  onPressed: home.lockApplication,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _buildSectionHeader('appearance'.tr, isDark),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text('theme'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Obx(
                      () => DropdownButton<ThemeMode>(
                        value: theme.themeMode.value,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                              value: ThemeMode.light, child: Text('light'.tr)),
                          DropdownMenuItem(
                              value: ThemeMode.dark, child: Text('dark'.tr)),
                          DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('system'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) theme.changeTheme(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language Section
            _buildSectionHeader('language'.tr, isDark),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text('language'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Obx(
                      () => DropdownButton<String>(
                        value: locale.locale.value.languageCode,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                              value: 'ar', child: Text('arabic'.tr)),
                          DropdownMenuItem(
                              value: 'en', child: Text('english'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) locale.changeLanguage(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Currency Section
            _buildSectionHeader('currency'.tr, isDark),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.currency_exchange_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text('currency'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Obx(
                      () => DropdownButton<String>(
                        value: home.selectedCurrency.value,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                              value: 'YER', child: Text('currency_yer'.tr)),
                          DropdownMenuItem(
                              value: 'SAR', child: Text('currency_sar'.tr)),
                          DropdownMenuItem(
                              value: 'USD', child: Text('currency_usd'.tr)),
                        ],
                        onChanged: (val) {
                          if (val != null) home.setCurrency(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Security Section
            _buildSectionHeader('security'.tr, isDark),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_reset_outlined,
                    color: AppColors.primary),
                title: Text('lock_app'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('pin_subtitle'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: home.lockApplication,
              ),
            ),

            const SizedBox(height: 16),

            // Database & Offline Backup Info
            _buildSectionHeader('database_backup'.tr, isDark),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.storage_outlined,
                        color: AppColors.success, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SQLite Local Database',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'backup_desc'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}
