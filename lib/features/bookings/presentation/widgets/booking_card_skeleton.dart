import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppSkeleton(height: 18, width: 160, borderRadius: 4),
              AppSkeleton(height: 22, width: 75, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 8),
          const AppSkeleton(height: 14, width: 120, borderRadius: 4),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),
          Row(
            children: const [
              AppSkeleton(height: 14, width: 14, borderRadius: 3),
              SizedBox(width: 8),
              AppSkeleton(height: 14, width: 180, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              AppSkeleton(height: 14, width: 14, borderRadius: 3),
              SizedBox(width: 8),
              AppSkeleton(height: 14, width: 140, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppSkeleton(height: 18, width: 70, borderRadius: 4),
              AppSkeleton(height: 16, width: 90, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
