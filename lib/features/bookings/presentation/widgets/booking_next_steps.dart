import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/widgets/app_card.dart';

class BookingNextSteps extends StatelessWidget {
  const BookingNextSteps({super.key});

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "What's Next?",
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStepItem(
            icon: Icons.verified_user_outlined,
            title: 'Partner Assignment',
            description:
                'A verified service professional will be assigned to your booking prior to the scheduled slot.',
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            icon: Icons.schedule_rounded,
            title: 'On-time Arrival',
            description:
                'Your professional will arrive at the scheduled time with all necessary equipment and cleaning supplies.',
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            icon: Icons.receipt_long_outlined,
            title: 'Manage Booking',
            description:
                'You can review booking progress, details, and updates from the My Bookings section.',
          ),
        ],
      ),
    );
  }
}
