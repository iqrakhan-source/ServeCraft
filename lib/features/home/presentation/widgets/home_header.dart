import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SC Branding + Location / Address Information
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.addressSelection,
                arguments: {'isSelectionMode': true},
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                // SC Branding Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SC',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Home',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        homeProvider.currentAddress,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Notification Bell
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            key: const Key('dashboard_notification_button'),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            tooltip: 'Notifications',
            splashRadius: 20,
            onPressed: () {},
          ),
        ),

        const SizedBox(width: 8),

        // Profile Icon Button
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            key: const Key('dashboard_profile_button'),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            tooltip: 'Profile',
            splashRadius: 20,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ),
      ],
    );
  }
}
