import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Sophia Reynolds';
    final displayPhone =
        user?.phone.isNotEmpty == true ? AppFormatters.formatPhone(user!.phone) : '+91 98765 43210';
    final displayEmail =
        user?.email.isNotEmpty == true ? user!.email : 'sophia.reynolds@example.com';
    final displayGender = user?.gender ?? 'Female';
    final displayDob = user?.dateOfBirth ?? '15 Aug 1996';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Customer Profile',
        showBackButton: !isTab,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Card Header
            AppCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          displayName.substring(0, 1).toUpperCase(),
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayPhone,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayEmail,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender & DOB pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              displayGender,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cake_outlined,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              displayDob,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile CTA
                  AppButton(
                    text: 'Edit Profile',
                    variant: AppButtonVariant.secondary,
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Entries Card
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.primary),
                    ),
                    title: Text('My Appointments',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    subtitle: Text('Upcoming, completed & cancelled visits',
                        style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.myBookings);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 20, color: AppColors.secondary),
                    ),
                    title: Text('Notifications',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    subtitle: Text('Booking alerts, stylist updates & offers',
                        style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.notifications);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_outlined,
                          size: 20, color: AppColors.primary),
                    ),
                    title: Text('Salon Branches',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    subtitle: Text('Explore active salon lounges & locations',
                        style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.branchSelection,
                        arguments: {'isSelectionMode': false},
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_offer_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ),
                    title: Text('Coupons & Offers',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    subtitle: Text('Exclusive salon discounts & gift packages',
                        style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.offers);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ),
                    title: Text('App Settings & Preferences',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    subtitle: Text('Language, notifications, privacy',
                        style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textTertiary),
                    onTap: () => _showSettingsSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            AppButton(
              text: 'Sign Out',
              variant: AppButtonVariant.dangerOutline,
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.error),
              onPressed: () => _confirmLogout(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Luxe Salon & Spa v1.0.0 (Customer App)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferences & Settings',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Appointment Reminders',
                    style: AppTypography.bodyMedium),
                subtitle: Text('Receive SMS/push 2 hours before slot',
                    style: AppTypography.bodySmall),
                value: true,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {},
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Promotional Offers',
                    style: AppTypography.bodyMedium),
                subtitle: Text('Notifications for weekend deals & coupons',
                    style: AppTypography.bodySmall),
                value: true,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Done',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from Luxe Salon?',
      confirmText: 'Sign Out',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.mobileLogin,
          (route) => false,
        );
      }
    }
  }
}
