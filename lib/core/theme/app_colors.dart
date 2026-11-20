import 'package:flutter/material.dart';

/// AppColors provides a refined, prestigious, and exceptionally eye-comfortable color palette
/// crafted specifically for high-end Real Estate and Property Management (Aqari).
///
/// Palette Identity: Charcoal Graphite & Matte Champagne Gold (الرمادي الفحمي الفاخر والذهب الشمبانيا المطفي)
/// Neutral, modern, glare-free, and deeply soothing to human vision.
class AppColors {
  AppColors._();

  // --- Brand & Primary Colors (Matte Champagne Gold) ---
  /// Matte Champagne Gold - soft, warm, regal, and exceptionally comfortable to the eyes.
  static const Color primary = Color(0xFFBF9B68);
  static const Color primaryLight = Color(0xFFD4B386);
  static const Color primaryDark = Color(0xFFA07E4E);

  // --- Secondary & Accent Colors (Luminous Gold & Executive Charcoal) ---
  /// Luminous Champagne Gold - used for high-value metrics, highlights, and VIP badges.
  static const Color accent = Color(0xFFD4B386);
  static const Color accentLight = Color(0xFFE8D1B0);

  /// Executive Charcoal Slate - used for secondary buttons, subtle metadata, and quiet icons.
  static const Color secondary = Color(0xFF6B6E75);
  static const Color secondaryLight = Color(0xFF8F939C);

  // --- Functional & Status Colors (Crisp & Restful) ---
  /// Muted Emerald Green - Indicates paid invoices, active contracts, and available properties.
  static const Color success = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E9);

  /// Warm Amber - Indicates pending drafts, partially paid invoices, and upcoming renewals.
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  /// Rich Crimson Red - Indicates overdue amounts, terminated contracts, and urgent alerts.
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  /// Champagne Gold Info - Indicates property specifications and general notices.
  static const Color info = Color(0xFFBF9B68);
  static const Color infoContainer = Color(0xFFF5EFE6);

  // --- Background & Neutral Colors (Light Theme - Pearl Alabaster) ---
  /// Crisp Pearl White background - modern, clean, and spacious.
  static const Color lightBackground = Color(0xFFF9F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF18191B);
  static const Color lightTextSecondary = Color(0xFF4B4F58);
  static const Color lightTextMuted = Color(0xFF8A909D);

  // --- Background & Neutral Colors (Dark Theme - Matte Charcoal Gray) ---
  /// Deep Matte Charcoal Black - zero color fatigue, 100% resting comfort on human vision.
  static const Color darkBackground = Color(0xFF121315);
  static const Color darkSurface = Color(0xFF1B1C1F);
  static const Color darkCard = Color(0xFF1B1C1F);
  static const Color darkBorder = Color(0xFF2C2E33);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A4AC);
  static const Color darkTextMuted = Color(0xFF6C707A);

  // --- Modern Architectural Gradients ---
  /// Primary Matte Champagne Gold Gradient for executive headers and financial portfolio cards.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFBF9B68), Color(0xFFD4B386)],
  );

  /// Executive Charcoal Stone gradient for night-mode executive cards.
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF1B1C1F), Color(0xFF24262B)],
  );

  /// Radiant Gold gradient for VIP badges, achievement highlights, and high-value revenue.
  static const LinearGradient goldGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFBF9B68), Color(0xFFDFCAAA)],
  );
}
