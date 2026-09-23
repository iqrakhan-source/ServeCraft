import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/addresses/presentation/providers/address_provider.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/date_time/presentation/providers/date_time_provider.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:prop_crm/features/services/presentation/providers/service_details_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/booking_summary_model.dart';
import '../providers/booking_summary_provider.dart';
import '../widgets/summary_address_card.dart';
import '../widgets/summary_price_details_card.dart';
import '../widgets/summary_schedule_card.dart';
import '../widgets/summary_service_card.dart';

class BookingSummaryScreen extends StatefulWidget {
  final ServiceModel? service;
  final ServicePackageModel? package;
  final AddressModel? address;
  final ServiceDateModel? scheduledDate;
  final TimeSlotModel? timeSlot;
  final BookingSummaryModel? initialSummary;

  const BookingSummaryScreen({
    super.key,
    this.service,
    this.package,
    this.address,
    this.scheduledDate,
    this.timeSlot,
    this.initialSummary,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSummary();
    });
  }

  void _initializeSummary() {
    final summaryProvider = context.read<BookingSummaryProvider>();

    if (widget.initialSummary != null) {
      summaryProvider.setSummary(widget.initialSummary!);
      return;
    }

    if (summaryProvider.summary != null && summaryProvider.summary!.isValid) {
      return;
    }

    // Resolve selections from widget parameters or existing providers
    ServiceModel? service = widget.service;
    ServicePackageModel? package = widget.package;
    AddressModel? address = widget.address;
    ServiceDateModel? scheduledDate = widget.scheduledDate;
    TimeSlotModel? timeSlot = widget.timeSlot;

    try {
      service ??= context.read<ServiceDetailsProvider>().service;
      package ??= context.read<ServiceDetailsProvider>().selectedPackage;
    } catch (_) {}

    try {
      address ??= context.read<AddressProvider>().selectedAddress ??
          context.read<AddressProvider>().defaultAddress;
    } catch (_) {}

    try {
      scheduledDate ??= context.read<DateTimeProvider>().selectedDate;
      timeSlot ??= context.read<DateTimeProvider>().selectedTimeSlot;
    } catch (_) {}

    // Only load if all 5 selections exist
    if (service != null &&
        package != null &&
        address != null &&
        scheduledDate != null &&
        timeSlot != null) {
      summaryProvider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );
    }
  }

  Future<void> _handleEditAddress() async {
    final updatedAddress = await Navigator.of(context).pushNamed(
      AppRoutes.addressSelection,
      arguments: {'isSelectionMode': true},
    );

    if (updatedAddress is AddressModel && mounted) {
      context.read<BookingSummaryProvider>().updateAddress(updatedAddress);
    }
  }

  Future<void> _handleEditSchedule(BookingSummaryModel summary) async {
    final updatedSchedule = await Navigator.of(context).pushNamed(
      AppRoutes.dateTimeSelection,
      arguments: {
        'serviceId': summary.service.id,
        'serviceName': summary.service.name,
        'packageId': summary.package.id,
        'packageName': summary.package.name,
      },
    );

    if (updatedSchedule is Map<String, dynamic> && mounted) {
      final date = updatedSchedule['selectedDate'] as ServiceDateModel?;
      final slot = updatedSchedule['selectedTimeSlot'] as TimeSlotModel?;
      if (date != null && slot != null) {
        context.read<BookingSummaryProvider>().updateSchedule(date, slot);
      }
    }
  }

  void _handleProceedToPayment(BookingSummaryModel summary) {
    Navigator.of(context).pushNamed(
      AppRoutes.payment,
      arguments: {
        'bookingSummary': summary,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryProvider = context.watch<BookingSummaryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Review Booking',
      ),
      body: Builder(
        builder: (context) {
          // 1. Loading State
          if (summaryProvider.isLoading) {
            return _buildLoadingState();
          }

          // 2. Error State
          if (summaryProvider.hasError) {
            return AppErrorView(
              message: summaryProvider.errorMessage ??
                  "Couldn't load booking summary",
              onRetry: _initializeSummary,
            );
          }

          final summary = summaryProvider.summary;

          // 3. Incomplete / Missing selections validation
          if (summary == null || !summary.isValid) {
            return _buildIncompleteState();
          }

          // 4. Valid Booking Summary Review
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Card
                SummaryServiceCard(
                  service: summary.service,
                  package: summary.package,
                ),
                const SizedBox(height: 16),

                // Scheduled Appointment Card
                SummaryScheduleCard(
                  scheduledDate: summary.scheduledDate,
                  timeSlot: summary.timeSlot,
                  onEdit: () => _handleEditSchedule(summary),
                ),
                const SizedBox(height: 16),

                // Address Card
                SummaryAddressCard(
                  address: summary.address,
                  onEdit: _handleEditAddress,
                ),
                const SizedBox(height: 16),

                // Pricing Breakdown Card
                SummaryPriceDetailsCard(
                  pricing: summary.pricing,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),

      // Sticky Bottom CTA Bar
      bottomNavigationBar: summaryProvider.isValid
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    offset: Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Price summary
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(
                              summaryProvider.summary!.pricing.totalAmount,
                            ),
                            style: AppTypography.priceLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Primary CTA
                    Expanded(
                      flex: 6,
                      child: AppButton(
                        text: 'Continue to Payment',
                        onPressed: () =>
                            _handleProceedToPayment(summaryProvider.summary!),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIncompleteState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Details Incomplete',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Some required booking information is missing. Please complete all previous steps before reviewing the summary.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Go Back',
              isFullWidth: false,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service skeleton
          AppSkeleton(height: 96, width: double.infinity, borderRadius: 14),
          SizedBox(height: 16),

          // Schedule skeleton
          AppSkeleton(height: 104, width: double.infinity, borderRadius: 14),
          SizedBox(height: 16),

          // Address skeleton
          AppSkeleton(height: 96, width: double.infinity, borderRadius: 14),
          SizedBox(height: 16),

          // Price skeleton
          AppSkeleton(height: 180, width: double.infinity, borderRadius: 14),
        ],
      ),
    );
  }
}
