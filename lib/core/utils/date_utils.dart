import 'package:intl/intl.dart';

/// DateFormatterUtils provides helper methods for date manipulation, formatting,
/// and contract period calculations for the real estate management system.
class DateFormatterUtils {
  DateFormatterUtils._();

  static final DateFormat _standardFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');

  /// Formats a [DateTime] into a standard ISO-style string (yyyy-MM-dd) for SQLite storage.
  static String toIsoDate(DateTime date) {
    return _standardFormat.format(date);
  }

  /// Formats a [DateTime] into a user-friendly display date (dd/MM/yyyy).
  static String toDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Formats an ISO string (yyyy-MM-dd) into display date (dd/MM/yyyy).
  static String formatIsoDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return _displayFormat.format(date);
    } catch (_) {
      return isoString;
    }
  }

  /// Parses an ISO string (yyyy-MM-dd) into [DateTime].
  static DateTime? parseIsoDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Calculates the next due date given a start date and cycle.
  /// Supported cycles: 'monthly', 'quarterly', 'semiAnnual', 'annual'.
  static DateTime calculateNextDueDate(DateTime fromDate, String cycle) {
    switch (cycle.toLowerCase()) {
      case 'quarterly':
        return DateTime(fromDate.year, fromDate.month + 3, fromDate.day);
      case 'semiannual':
        return DateTime(fromDate.year, fromDate.month + 6, fromDate.day);
      case 'annual':
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
      case 'monthly':
      default:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
    }
  }

  /// Calculates number of days remaining until an expiration date.
  /// Returns negative value if already expired.
  static int daysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  /// Formats a [DateTime] into a rich full date string in Arabic
  /// e.g. "الخميس، 19 نوفمبر 2026"
  static String formatArabicFullDate(DateTime date) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName، ${date.day} $monthName ${date.year}';
  }
}
