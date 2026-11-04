import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:provider/provider.dart';

import '../../../booking_summary/presentation/providers/booking_summary_provider.dart';
import '../../data/models/create_booking_response_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_confirmation_card.dart';
import '../widgets/booking_next_steps.dart';
import '../widgets/booking_summary_success_card.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final CreateBookingResponseModel? booking;
  final BookingSummaryModel? summary;

  const BookingConfirmationScreen({
    super.key,
    this.booking,
    this.summary,
  });

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.mainNav,
          (route) => false,
    );
  }

  void _navigateToMyBookings(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.myBookings);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBooking =
        booking ?? context.watch<BookingProvider>().createdBooking;

    final effectiveSummary =
        summary ?? context.watch<BookingSummaryProvider>().summary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Booking Confirmation',
          showBackButton: true,
          onBackPressed: () => _navigateToHome(context),
        ),
        body: effectiveBooking == null || effectiveSummary == null
            ? _buildEmptyState(context)
            : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking Confirmed',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your service has been successfully scheduled.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  BookingConfirmationCard(
                    bookingReference:
                    effectiveBooking.appointment.appointmentCode,
                    statusText:
                    effectiveBooking.appointment.status,
                  ),
                  const SizedBox(height: 16),

                  BookingSummarySuccessCard(
                    booking: effectiveBooking,
                    summary: effectiveSummary,
                  ),
                  const SizedBox(height: 16),

                  const BookingNextSteps(),
                  const SizedBox(height: 32),

                  AppButton(
                    text: 'Back to Home',
                    onPressed: () => _navigateToHome(context),
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    text: 'View My Bookings',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _navigateToMyBookings(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Booking Found',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No completed booking was found to display.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Return to Home',
              isFullWidth: false,
              variant: AppButtonVariant.secondary,
              onPressed: () => _navigateToHome(context),
            ),
          ],
        ),
      ),
    );
  }
}