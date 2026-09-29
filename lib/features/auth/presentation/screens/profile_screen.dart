import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_dialog.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                user != null && user.name.isNotEmpty
                    ? user.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user != null && user.name.isNotEmpty ? user.name : 'User',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              user != null && user.phone.isNotEmpty ? AppFormatters.formatPhone(user.phone) : '',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            if (user != null && user.email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                user.email,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
            ],
            const SizedBox(height: 32),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    title: Text('Profile Completion Status', style: AppTypography.titleSmall),
                    trailing: Text(
                      user?.isProfileComplete == true ? 'Complete' : 'Incomplete',
                      style: TextStyle(
                        color: user?.isProfileComplete == true ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                    title: Text('My Bookings', style: AppTypography.titleSmall),
                    subtitle: Text('View active and past bookings', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.myBookings);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: Text('Saved Addresses', style: AppTypography.titleSmall),
                    subtitle: Text('Manage delivery addresses', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.addressSelection,
                        arguments: {'isSelectionMode': false},
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                    title: Text('User ID', style: AppTypography.titleSmall),
                    subtitle: Text(user?.id ?? 'N/A', style: AppTypography.bodySmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Sign Out',
              variant: AppButtonVariant.danger,
              icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to end your session?',
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
