import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// StatusBadge displays an elegant, rounded tag indicating the state of an entity.
///
/// Supported entities:
/// - Units: vacant, rented, maintenance, unavailable, reserved, archived
/// - Contracts: draft, active, expired, terminated, cancelled
/// - Invoices: draft, pending, partiallyPaid, paid, overdue, cancelled
/// - Payments: normal, reversed
class StatusBadge extends StatelessWidget {
  /// The raw status key string
  final String status;

  /// Localized display label
  final String label;

  /// Optional custom override color
  final Color? customColor;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(status);
    final effectiveColor = customColor ?? colors.color;
    final effectiveBg = effectiveColor.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: effectiveColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusColor _resolveColors(String statusKey) {
    switch (statusKey.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'vacant':
        return _StatusColor(color: AppColors.success);

      case 'pending':
      case 'partiallypaid':
      case 'draft':
      case 'reserved':
        return _StatusColor(color: AppColors.warning);

      case 'overdue':
      case 'terminated':
      case 'cancelled':
      case 'reversed':
        return _StatusColor(color: AppColors.error);

      case 'rented':
      case 'info':
        return _StatusColor(color: AppColors.info);

      case 'maintenance':
      case 'unavailable':
      case 'expired':
      case 'archived':
      default:
        return _StatusColor(color: AppColors.secondary);
    }
  }
}

class _StatusColor {
  final Color color;
  _StatusColor({required this.color});
}
