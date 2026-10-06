import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:provider/provider.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_status_badge.dart';
import '../widgets/cancellation_reason_sheet.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final BookingModel? initialBooking;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.initialBooking,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialBooking != null) {
          context.read<BookingProvider>().setSelectedBooking(widget.initialBooking);
        }
        if (widget.bookingId.isNotEmpty) {
          context.read<BookingProvider>().loadBookingDetails(widget.bookingId);
        }
      }
    });
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Booking ID copied to clipboard',
              style: AppTypography.bodySmall.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleCancelBooking(BookingModel booking) async {
    final success =
        await CancellationReasonSheet.show(context, booking: booking);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Booking cancelled successfully',
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final booking = provider.selectedBooking ?? widget.initialBooking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Booking Details',
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBody(context, provider, booking),
        ),
      ),
      bottomNavigationBar: (booking != null &&
              (booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.pending ||
                  booking.status == BookingStatus.rescheduled))
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Policy: Free cancellation & rescheduling up to 2 hours prior.',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Reschedule',
                            variant: AppButtonVariant.outline,
                            onPressed: () =>
                                _handleRescheduleBooking(booking),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Cancel Appointment',
                            variant: AppButtonVariant.dangerOutline,
                            onPressed: () => _handleCancelBooking(booking),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _handleRescheduleBooking(BookingModel booking) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.dateTimeSelection,
      arguments: {
        'serviceId': booking.service.id,
        'serviceName': booking.service.name,
        'packageId': booking.package.id,
        'packageName': booking.package.name,
      },
    );

    if (result is Map<String, dynamic> && mounted) {
      final newDate = result['selectedDate'] as ServiceDateModel?;
      final newSlot = result['selectedTimeSlot'] as TimeSlotModel?;

      if (newDate != null && newSlot != null) {
        final updated = await context.read<BookingProvider>().rescheduleBooking(
              bookingId: booking.id,
              newDate: newDate,
              newSlot: newSlot,
            );

        if (updated != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment rescheduled to ${newDate.dayName}, ${newDate.dayNumber} ${newDate.monthName} at ${newSlot.formattedLabel}',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Widget _buildBody(
    BuildContext context,
    BookingProvider provider,
    BookingModel? booking,
  ) {
    if (provider.isLoadingDetails && booking == null) {
      return _buildLoadingSkeleton();
    }

    if (booking == null) {
      return _buildNotFoundState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Banner
          _buildStatusBanner(booking),
          const SizedBox(height: 16),

          // 2. Booking ID & Reference
          _buildReferenceCard(context, booking),
          const SizedBox(height: 16),

          // 3. Customer Information
          _buildCustomerSection(booking),
          const SizedBox(height: 16),

          // 4. Salon Branch Location
          _buildAddressSection(booking),
          const SizedBox(height: 16),

          // 5. Service & Package
          _buildServiceSection(booking),
          const SizedBox(height: 16),

          // 6. Schedule
          _buildScheduleSection(booking),
          const SizedBox(height: 16),

          // 7. Payment Information
          _buildPaymentSection(booking),
          const SizedBox(height: 16),

          // 8. Price Breakdown
          _buildPriceBreakdownSection(booking),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BookingModel booking) {
    String statusDescription;
    IconData bannerIcon;
    Color accentColor;
    Color bgColor;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusDescription =
            'Your appointment is confirmed. Please arrive at the salon 10 minutes prior to your scheduled time.';
        bannerIcon = Icons.check_circle_outline_rounded;
        accentColor = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case BookingStatus.pending:
        statusDescription =
            'Your appointment is currently pending confirmation from our salon concierge.';
        bannerIcon = Icons.schedule_rounded;
        accentColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case BookingStatus.completed:
        statusDescription =
            'This treatment was successfully completed. Thank you for choosing Luxe Salon & Spa!';
        bannerIcon = Icons.task_alt_rounded;
        accentColor = AppColors.info;
        bgColor = AppColors.infoLight;
        break;
      case BookingStatus.cancelled:
        statusDescription = booking.cancellationReason != null &&
                booking.cancellationReason!.isNotEmpty
            ? 'This appointment was cancelled. Reason: ${booking.cancellationReason}.'
            : 'This appointment was cancelled. No cancellation fee was incurred.';
        bannerIcon = Icons.cancel_outlined;
        accentColor = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case BookingStatus.rescheduled:
        statusDescription =
            'Your appointment has been successfully rescheduled to a new time slot.';
        bannerIcon = Icons.update_rounded;
        accentColor = const Color(0xFF6D28D9);
        bgColor = const Color(0xFFEDE9FE);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(bannerIcon, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.status.displayName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BookingStatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusDescription,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                if (booking.status == BookingStatus.cancelled &&
                    booking.cancellationNote != null &&
                    booking.cancellationNote!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Note: "${booking.cancellationNote}"',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(BuildContext context, BookingModel booking) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Reference ID',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.formattedBookingReference,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            tooltip: 'Copy Reference ID',
            onPressed: () => _copyToClipboard(context, booking.bookingReference),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BookingModel booking) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.service.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.package.name} • ${booking.package.duration}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (booking.package.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 10),
            Text(
              'Included in Package:',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            ...booking.package.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BookingModel booking) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Date & Time',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.scheduledDate.dayName}, ${booking.scheduledDate.dayNumber} ${booking.scheduledDate.monthName} ${booking.scheduledDate.date.year}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.timeSlot.formattedLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(BookingModel booking) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Details',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CLIENT',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  'SR',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sophia Reynolds',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+91 98765 43210 • sophia.reynolds@example.com',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BookingModel booking) {
    final branchName = booking.branch?.name ?? 'Downtown Luxury Lounge';
    final branchAddress = booking.branch?.address ??
        '104 Royal Palms, Downtown Luxury Avenue, Mumbai';
    final branchHours = booking.branch?.formattedHours ?? '09:00 AM - 09:00 PM';
    final branchPhone = booking.branch?.phone ?? '+91 98765 43210';

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Salon Branch Location',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CONFIRMED SALON',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            branchName,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  branchAddress,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                branchHours,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                branchPhone,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BookingModel booking) {
    final isOnline = booking.paymentMethod.type.toFormattedString() != 'cod';

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isOnline
                          ? Icons.credit_card_rounded
                          : Icons.storefront_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline
                                ? booking.paymentMethod.title
                                : 'Pay at Salon (Cash / Card)',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOnline
                                ? 'Prepaid Online'
                                : 'Pay at Reception Desk',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOnline ? 'PAID ONLINE' : 'PAY AT SALON',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isOnline
                        ? AppColors.success
                        : AppColors.warning,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownSection(BookingModel booking) {
    final pricing = booking.pricing;

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Package Price',
            AppFormatters.formatCurrency(pricing.packagePrice),
          ),
          if (pricing.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Discount',
              '-${AppFormatters.formatCurrency(pricing.discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 8),
          _buildPriceRow(
            'Taxes & Service Fees (${pricing.taxRate.toStringAsFixed(0)}%)',
            AppFormatters.formatCurrency(pricing.taxAmount),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Amount',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppFormatters.formatCurrency(pricing.totalAmount),
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: const [
          AppSkeleton(height: 80, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),
          AppSkeleton(height: 70, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),
          AppSkeleton(height: 120, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),
          AppSkeleton(height: 90, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),
          AppSkeleton(height: 110, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),
          AppSkeleton(height: 150, width: double.infinity, borderRadius: 12),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking not found',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This booking may no longer be available.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Back to My Bookings',
              isFullWidth: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
