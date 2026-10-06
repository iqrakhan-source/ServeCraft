import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
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
                  fontWeight: FontWeight.w700,
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
                Icons.spa_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Salon Visit Guidelines",
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
            icon: Icons.access_time_rounded,
            title: 'Arrive 10 Mins Early',
            description:
                'Please arrive 10 minutes prior to your slot. Valet parking & complimentary beverages are available upon arrival.',
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            icon: Icons.person_pin_rounded,
            title: 'Stylist Consultation',
            description:
                'Your dedicated master stylist will conduct a personalized consultation before beginning your treatment.',
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            icon: Icons.payment_rounded,
            title: 'Check-out & Reception',
            description:
                'If you chose "Pay at Salon", you can conveniently pay at the reception desk after your service via Cash, Card, or UPI.',
          ),
        ],
      ),
    );
  }
}
