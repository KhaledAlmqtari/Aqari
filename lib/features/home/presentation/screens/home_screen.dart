import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../contracts/presentation/screens/contract_form_screen.dart';
import '../../../contracts/presentation/screens/contracts_finance_hub_screen.dart';
import '../../../invoices/presentation/screens/invoice_form_screen.dart';
import '../../../properties/presentation/screens/property_form_screen.dart';
import '../../../properties/presentation/screens/property_list_screen.dart';
import '../../../tenants/presentation/screens/tenant_form_screen.dart';
import '../../../tenants/presentation/screens/tenant_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../about/presentation/screens/about_app_screen.dart';
import '../../../about/presentation/screens/about_developer_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/settings_tab.dart';

/// HomeScreen provides the primary executive shell for the Real Estate Management app (Aqari).
///
/// Features:
/// - Custom top app bar with "Aqari", full Arabic date, 3-dots popup menu, refresh, and theme toggle.
/// - Sleek floating capsule bottom navigation bar with rounded edges matching the user's reference.
/// - Exact 3-action floating arc speed dial right above the center button:
///   1. Top Center (Amber glowing circle): إضافة عقار
///   2. Left (Blue glowing circle): إنشاء عقد
///   3. Right (Red glowing circle): إنشاء فاتورة
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find<HomeController>();

  /// Tracks visibility of the floating 3-action speed dial
  bool _isSpeedDialOpen = false;

  void _toggleSpeedDial() {
    setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
  }

  void _closeSpeedDial() {
    if (_isSpeedDialOpen) {
      setState(() => _isSpeedDialOpen = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'logout'.tr,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'confirm_logout'.tr,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final activeIndex = controller.currentTabIndex.value;

    // 1. Dashboard Tab Bar (Aqari title with Arabic date & 3 dots menu)
    if (activeIndex == 0) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aqari',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatterUtils.formatArabicFullDate(DateTime.now()),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          centerTitle: true,
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.to(() => const ProfileScreen());
                  break;
                case 'settings':
                  controller.changeTab(4);
                  break;
                case 'about_app':
                  Get.to(() => const AboutAppScreen());
                  break;
                case 'about_developer':
                  Get.to(() => const AboutDeveloperScreen());
                  break;
                case 'logout':
                  _showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 12),
                    Text('profile'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text('settings'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'about_app',
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 12),
                    Text('about_app'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'about_developer',
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 20),
                    const SizedBox(width: 12),
                    Text('about_developer'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'logout'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 22),
              tooltip: 'تحديث',
              onPressed: () => controller.loadDashboardData(),
            ),
            IconButton(
              icon: Icon(
                controller.themeController.themeMode.value == ThemeMode.dark
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round_outlined,
                size: 22,
              ),
              tooltip: 'theme'.tr,
              onPressed: controller.themeController.toggleTheme,
            ),
            const SizedBox(width: 4),
          ],
        ),
      );
    }

    // 2. Sub-screens AppBars (With back arrow to Home and direct + add button)
    String title = '';
    VoidCallback? onAdd;

    switch (activeIndex) {
      case 1:
        title = 'properties'.tr;
        onAdd = () async {
          final res = await Get.to(() => const PropertyFormScreen());
          if (res == true) controller.loadDashboardData();
        };
        break;
      case 2:
        title = 'contracts_and_finance'.tr;
        onAdd = () async {
          final res = await Get.to(() => const ContractFormScreen());
          if (res == true) controller.loadDashboardData();
        };
        break;
      case 3:
        title = 'tenants'.tr;
        onAdd = () async {
          final res = await Get.to(() => const TenantFormScreen());
          if (res == true) controller.loadDashboardData();
        };
        break;
      case 4:
        title = 'settings'.tr;
        break;
    }

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        tooltip: 'الرئيسية',
        onPressed: () => controller.changeTab(0),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            tooltip: 'إضافة',
            onPressed: onAdd,
          ),
        const SizedBox(width: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const DashboardTab(),
      const PropertyListScreen(showAppBar: false),
      const ContractsFinanceHubScreen(isEmbedded: true),
      const TenantListScreen(showAppBar: false),
      const SettingsTab(showAppBar: false),
    ];

    return Obx(
      () => Scaffold(
        appBar: _buildAppBar(context, isDark),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 74),
              child: IndexedStack(
                index: controller.currentTabIndex.value,
                children: pages,
              ),
            ),

            // Backdrop dismissal layer when Speed Dial is active
            if (_isSpeedDialOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeSpeedDial,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ),

            // Unified Floating Capsule Bar & Tight 3-Action Speed Dial
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildModernFloatingBarWithSpeedDial(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual glowing circular Speed Dial action with black pill label underneath
  Widget _buildDialItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds floating capsule bottom navigation bar with tightly clustered 3-action Speed Dial
  Widget _buildModernFloatingBarWithSpeedDial(
      BuildContext context, bool isDark) {
    final activeIndex = controller.currentTabIndex.value;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _isSpeedDialOpen ? 210 : 84,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. Floating Capsule Dock Bar
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1C1F) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2E33)
                        : AppColors.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    // Tab 0: Dashboard (الرئيسية)
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        icon: Icons.grid_view_rounded,
                        label: 'dashboard'.tr,
                        isSelected: activeIndex == 0,
                        onTap: () {
                          _closeSpeedDial();
                          controller.changeTab(0);
                        },
                        isDark: isDark,
                      ),
                    ),

                    // Tab 1: Properties (العقارات)
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        icon: Icons.apartment_rounded,
                        label: 'properties'.tr,
                        isSelected: activeIndex == 1,
                        onTap: () {
                          _closeSpeedDial();
                          controller.changeTab(1);
                        },
                        isDark: isDark,
                      ),
                    ),

                    // Space for center elevated button
                    const SizedBox(width: 56),

                    // Tab 2: Contracts & Finance (العقود والمالية)
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        icon: Icons.receipt_long_rounded,
                        label: 'contracts_and_finance'.tr,
                        isSelected: activeIndex == 2,
                        onTap: () {
                          _closeSpeedDial();
                          controller.changeTab(2);
                        },
                        isDark: isDark,
                      ),
                    ),

                    // Tab 3: Tenants (المستأجرين)
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        icon: Icons.people_alt_rounded,
                        label: 'tenants'.tr,
                        isSelected: activeIndex == 3,
                        onTap: () {
                          _closeSpeedDial();
                          controller.changeTab(3);
                        },
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Exactly 3 Speed Dial Actions (Clustered tightly above the center button)
            if (_isSpeedDialOpen)
              Positioned(
                bottom: 58,
                child: SizedBox(
                  width: 240,
                  height: 125,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Center Top: إضافة عقار (Matte Champagne Gold Glowing Circle)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _buildDialItem(
                            icon: Icons.apartment_rounded,
                            label: 'إضافة عقار',
                            color: const Color(0xFFBF9B68),
                            glowColor:
                                const Color(0xFFBF9B68).withOpacity(0.45),
                            onTap: () async {
                              _closeSpeedDial();
                              final res = await Get.to(
                                  () => const PropertyFormScreen());
                              if (res == true) {
                                controller.loadDashboardData();
                              }
                            },
                          ),
                        ),
                      ),

                      // Left: إنشاء عقد (Luminous Champagne Circle)
                      Positioned(
                        left: 8,
                        bottom: 6,
                        child: _buildDialItem(
                          icon: Icons.description_rounded,
                          label: 'إنشاء عقد',
                          color: const Color(0xFFD4B386),
                          glowColor: const Color(0xFFD4B386).withOpacity(0.4),
                          onTap: () async {
                            _closeSpeedDial();
                            final res =
                                await Get.to(() => const ContractFormScreen());
                            if (res == true) {
                              controller.loadDashboardData();
                            }
                          },
                        ),
                      ),

                      // Right: إنشاء فاتورة (Soft Crimson Red Circle)
                      Positioned(
                        right: 8,
                        bottom: 6,
                        child: _buildDialItem(
                          icon: Icons.receipt_long_rounded,
                          label: 'إنشاء فاتورة',
                          color: const Color(0xFFDC2626),
                          glowColor: const Color(0xFFDC2626).withOpacity(0.4),
                          onTap: () async {
                            _closeSpeedDial();
                            final res =
                                await Get.to(() => const InvoiceFormScreen());
                            if (res == true) {
                              controller.loadDashboardData();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Center Elevated Action Button (+) - Matte Champagne Gold, protruding smoothly
            Positioned(
              bottom: 22,
              child: GestureDetector(
                onTap: _toggleSpeedDial,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                        0xFFBF9B68), // Matte Champagne Gold - soothing, prestigious, and glare-free
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFFBF9B68).withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: _isSpeedDialOpen ? 0.125 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
