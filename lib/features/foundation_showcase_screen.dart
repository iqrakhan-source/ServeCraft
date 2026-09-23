import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/utilities/extensions.dart';
import '../core/utilities/formatters.dart';
import '../core/widgets/app_badge.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_dialog.dart';
import '../core/widgets/app_empty_state.dart';
import '../core/widgets/app_error_view.dart';
import '../core/widgets/app_loading_indicator.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/custom_app_bar.dart';

class FoundationShowcaseScreen extends StatefulWidget {
  const FoundationShowcaseScreen({super.key});

  @override
  State<FoundationShowcaseScreen> createState() => _FoundationShowcaseScreenState();
}

class _FoundationShowcaseScreenState extends State<FoundationShowcaseScreen> {
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.instance;

    return Scaffold(
      appBar: CustomAppBar(
        title: appConfig.appName,
        subtitle: 'Phase 1 • Core Foundation & Design System',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              AppDialog.alert(
                context: context,
                title: 'System Information',
                message:
                    'App: ${appConfig.appName}\nVersion: ${appConfig.appVersion}\nEnvironment: ${appConfig.environment.name}\nBase URL: ${appConfig.apiBaseUrl}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Phase 1 Architecture & Design System Active',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Typography & Formatters Section
            Text('Typography & Formatters', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Medium', style: AppTypography.displayMedium),
                  const SizedBox(height: 4),
                  Text('Body Large - Inter font family', style: AppTypography.bodyLarge),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Currency Formatter:', style: AppTypography.bodyMedium),
                      Text(AppFormatters.formatCurrency(1499), style: AppTypography.priceMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date Formatter:', style: AppTypography.bodyMedium),
                      Text(AppFormatters.formatDate(DateTime.now()), style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Phone Formatter:', style: AppTypography.bodyMedium),
                      Text(AppFormatters.formatPhone('9876543210'), style: AppTypography.titleSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Buttons Section
            Text('Action Buttons', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppButton(
              text: 'Primary Button',
              isLoading: _isLoading,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 2));
                if (!mounted) return;
                setState(() => _isLoading = false);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Primary action executed!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Secondary Button',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.showSnackBar('Secondary clicked'),
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Outline Button',
              variant: AppButtonVariant.outline,
              onPressed: () {
                AppDialog.confirm(
                  context: context,
                  title: 'Confirm Action',
                  message: 'Are you sure you want to test this dialog?',
                );
              },
            ),
            const SizedBox(height: 28),

            // Form Inputs Section
            Text('Form Inputs', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phoneController,
              label: 'Mobile Number',
              hint: 'Enter 10-digit number',
              prefixText: '+91',
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: 'Customer Full Name',
              hint: 'e.g. Alex Morgan',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 28),

            // Status Badges Section
            Text('Centralized Status Badges', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppBadge.bookingStatus('PENDING'),
                AppBadge.bookingStatus('CONFIRMED'),
                AppBadge.bookingStatus('PROVIDER_ASSIGNED'),
                AppBadge.bookingStatus('PROVIDER_ON_THE_WAY'),
                AppBadge.bookingStatus('SERVICE_STARTED'),
                AppBadge.bookingStatus('COMPLETED'),
                AppBadge.bookingStatus('CANCELLED'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppBadge.paymentStatus('SUCCESS'),
                AppBadge.paymentStatus('PENDING'),
                AppBadge.paymentStatus('FAILED'),
                AppBadge.paymentStatus('REFUNDED'),
              ],
            ),
            const SizedBox(height: 28),

            // Loading & Skeletons Section
            Text('Loading States & Shimmers', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            const AppLoadingIndicator(message: 'Loading services...'),
            const SizedBox(height: 16),
            const AppSkeleton(height: 20, width: 220),
            const SizedBox(height: 8),
            const AppSkeleton(height: 14, width: double.infinity),
            const SizedBox(height: 8),
            const AppSkeleton(height: 14, width: 280),
            const SizedBox(height: 28),

            // Error View Example
            Text('Error & Empty State Components', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              child: AppErrorView(
                title: 'Connection Interrupted',
                message: 'Could not fetch services from the backend.',
                onRetry: () => context.showSnackBar('Retry triggered!'),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: AppEmptyState(
                title: 'No Bookings Yet',
                subtitle: 'Your active and past bookings will appear here.',
                actionText: 'Browse Services',
                onActionPressed: () => context.showSnackBar('Navigating to categories...'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
