import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import '../../data/models/booking_model.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    IconData iconData;

    switch (status) {
      case BookingStatus.confirmed:
        bg = AppColors.successLight;
        textColor = AppColors.success;
        iconData = Icons.check_circle_rounded;
        break;
      case BookingStatus.pending:
        bg = AppColors.warningLight;
        textColor = AppColors.warning;
        iconData = Icons.schedule_rounded;
        break;
      case BookingStatus.completed:
        bg = AppColors.infoLight;
        textColor = AppColors.info;
        iconData = Icons.task_alt_rounded;
        break;
      case BookingStatus.cancelled:
        bg = AppColors.errorLight;
        textColor = AppColors.error;
        iconData = Icons.cancel_rounded;
        break;
      case BookingStatus.rescheduled:
        bg = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF6D28D9);
        iconData = Icons.update_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
