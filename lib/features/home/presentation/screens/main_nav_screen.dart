import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
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
      _buildTabContent(
        title: 'Referral Program',
        icon: Icons.share_rounded,
        description: 'Invite friends & neighbors to ServeCraft and earn service rewards.',
        user: user,
      ),
      const MyBookingsScreen(isTab: true),
      _buildTabContent(
        title: AppStrings.navOffers,
        icon: Icons.local_offer_rounded,
        description: 'Scheduled for Phase 7: Offers & Discounts',
        user: user,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 || _currentIndex == 2
          ? null
          : CustomAppBar(
              title: _currentIndex == 1 ? 'Referral' : AppStrings.navOffers,
              showBackButton: false,
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
          items: [
            BottomNavigationBarItem(
              icon: Container(
                width: 26,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  'SC',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ),
              activeIcon: Container(
                width: 26,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SC',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.share_outlined),
              activeIcon: Icon(Icons.share_rounded),
              label: 'Referral',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer_rounded),
              label: 'Offers',
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
}
