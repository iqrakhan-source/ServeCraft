import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Widget? icon;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// Factory for Booking Status badge
  factory AppBadge.bookingStatus(String status) {
    Color text;
    Color bg;
    String display = status;

    switch (status.toUpperCase()) {
      case 'PENDING':
        text = AppColors.statusPending;
        bg = AppColors.warningLight;
        display = 'Pending';
        break;
      case 'CONFIRMED':
        text = AppColors.statusConfirmed;
        bg = AppColors.infoLight;
        display = 'Confirmed';
        break;
      case 'PROVIDER_ASSIGNED':
        text = AppColors.statusProviderAssigned;
        bg = const Color(0xFFEEF2FF);
        display = 'Expert Assigned';
        break;
      case 'PROVIDER_ON_THE_WAY':
        text = AppColors.statusProviderOnTheWay;
        bg = const Color(0xFFF3E8FF);
        display = 'On The Way';
        break;
      case 'SERVICE_STARTED':
        text = AppColors.statusServiceStarted;
        bg = const Color(0xFFCFFAFE);
        display = 'In Progress';
        break;
      case 'COMPLETED':
        text = AppColors.statusCompleted;
        bg = AppColors.successLight;
        display = 'Completed';
        break;
      case 'CANCELLED':
        text = AppColors.statusCancelled;
        bg = AppColors.errorLight;
        display = 'Cancelled';
        break;
      default:
        text = AppColors.textSecondary;
        bg = AppColors.surfaceMuted;
    }

    return AppBadge(
      label: display,
      textColor: text,
      backgroundColor: bg,
    );
  }

  /// Factory for Payment Status badge
  factory AppBadge.paymentStatus(String status) {
    Color text;
    Color bg;
    String display = status;

    switch (status.toUpperCase()) {
      case 'SUCCESS':
        text = AppColors.paymentSuccess;
        bg = AppColors.successLight;
        display = 'Paid';
        break;
      case 'PENDING':
        text = AppColors.paymentPending;
        bg = AppColors.warningLight;
        display = 'Payment Pending';
        break;
      case 'FAILED':
        text = AppColors.paymentFailed;
        bg = AppColors.errorLight;
        display = 'Failed';
        break;
      case 'REFUNDED':
        text = AppColors.paymentRefunded;
        bg = AppColors.surfaceMuted;
        display = 'Refunded';
        break;
      default:
        text = AppColors.textSecondary;
        bg = AppColors.surfaceMuted;
    }

    return AppBadge(
      label: display,
      textColor: text,
      backgroundColor: bg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
