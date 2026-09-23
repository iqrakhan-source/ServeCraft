import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_dialog.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    final tabs = [
      const HomeScreen(),
      const MyBookingsScreen(isTab: true),
      _buildTabContent(
        title: AppStrings.navOffers,
        icon: Icons.local_offer_rounded,
        description: 'Scheduled for Phase 7: Offers & Discounts',
        user: user,
      ),
      _buildProfileTabContent(user),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 || _currentIndex == 1
          ? null
          : CustomAppBar(
              title: _currentIndex == 3 ? 'My Profile' : AppStrings.appName,
              showBackButton: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  tooltip: 'Sign Out',
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          iconSize: 22,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTypography.labelSmall,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: AppStrings.navBookings,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer_rounded),
              label: AppStrings.navOffers,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required String title,
    required IconData icon,
    required String description,
    dynamic user,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Authenticated User Header Card
          AppCard(
            backgroundColor: AppColors.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    user?.name?.isNotEmpty == true
                        ? (user!.name as String).substring(0, 1).toUpperCase()
                        : 'U',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name?.isNotEmpty == true
                            ? user!.name
                            : 'Authenticated User',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phone != null
                            ? AppFormatters.formatPhone(user!.phone)
                            : '',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active Session',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Tab placeholder indicator
          Center(
            child: Column(
              children: [
                Icon(icon, size: 54, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(title, style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTabContent(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user?.name?.isNotEmpty == true
                  ? (user!.name as String).substring(0, 1).toUpperCase()
                  : 'U',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name?.isNotEmpty == true ? user!.name : 'User',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            user?.phone != null ? AppFormatters.formatPhone(user!.phone) : '',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (user?.email?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              user!.email,
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
                    setState(() => _currentIndex = 1);
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
