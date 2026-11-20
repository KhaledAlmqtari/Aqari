import 'package:intl/intl.dart';

/// MoneyUtils provides financial computation and formatting helper methods.
///
/// In compliance with architectural rules:
/// - Monetary amounts are NEVER handled or stored as floating-point [double].
/// - Amounts are stored as [int] in the smallest base currency unit.
/// - Formats amounts with proper thousand separators and currency symbol.
class MoneyUtils {
  MoneyUtils._();

  /// Default currency code as per user decision (Yemeni Rial)
  static const String defaultCurrencyCode = 'YER';
  static const String defaultCurrencySymbolAr = 'ر.ي';
  static const String defaultCurrencySymbolEn = 'YER';

  static final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  /// Formats an integer monetary amount into a localized string with currency symbol.
  /// Example: 150000 -> "150,000 ر.ي" (in Arabic) or "150,000 YER" (in English).
  static String format(int amount,
      {String? currencyCode, bool isArabic = true}) {
    final formattedNumber = _formatter.format(amount);
    final symbol =
        _resolveSymbol(currencyCode ?? defaultCurrencyCode, isArabic);
    return '$formattedNumber $symbol';
  }

  /// Formats an integer monetary amount without currency symbol (e.g. "150,000")
  static String formatNumberOnly(int amount) {
    return _formatter.format(amount);
  }

  /// Parses an input string (e.g. "150,000" or "150000") into an integer amount safely.
  /// Returns 0 if parsing fails.
  static int parse(String input) {
    if (input.trim().isEmpty) return 0;
    final cleaned = input.replaceAll(',', '').replaceAll(' ', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Helper to resolve currency symbols based on code and locale
  static String _resolveSymbol(String code, bool isArabic) {
    switch (code.toUpperCase()) {
      case 'YER':
        return isArabic ? 'ر.ي' : 'YER';
      case 'SAR':
        return isArabic ? 'ر.س' : 'SAR';
      case 'USD':
        return '\$';
      default:
        return code;
    }
  }
}
