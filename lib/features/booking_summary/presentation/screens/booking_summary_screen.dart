
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../addresses/data/models/address_model.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../../branches/presentation/providers/branch_provider.dart';
import '../../../branches/presentation/screens/branch_selection_screen.dart';
import '../../../date_time/data/models/service_date_model.dart';
import '../../../date_time/data/models/time_slot_model.dart';
import '../../../offers/presentation/providers/offer_provider.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/data/models/service_package_model.dart';
import '../../../services/data/models/service_products_response.dart';
import '../../data/models/booking_summary_model.dart';
import '../providers/booking_summary_provider.dart';
import '../widgets/summary_branch_card.dart';
import '../widgets/summary_coupon_card.dart';
import '../widgets/summary_price_details_card.dart';
import '../widgets/summary_schedule_card.dart';
import '../widgets/summary_service_card.dart';

class BookingSummaryScreen extends StatefulWidget {
  final ServiceModel? service;
  final ServicePackageModel? package;
  final AddressModel? address;
  final BranchModel? branch;
  final ServiceDateModel? scheduledDate;
  final TimeSlotModel? timeSlot;
  final BookingSummaryModel? initialSummary;
  final ConsumableProduct? selectedProduct;

  const BookingSummaryScreen({
    super.key,
    this.service,
    this.package,
    this.address,
    this.branch,
    this.scheduledDate,
    this.timeSlot,
    this.initialSummary,
    this.selectedProduct,
  });

  @override
  State<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
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
    final provider = context.read<BookingSummaryProvider>();

    if (widget.initialSummary != null) {
      final existingSummary = widget.initialSummary!;

      final selectedBranch = existingSummary.branch ??
          widget.branch ??
          context.read<BranchProvider>().selectedBranch;

      provider.setSummary(existingSummary);

      if (selectedBranch != null && existingSummary.branch == null) {
        provider.updateBranch(selectedBranch);
      }

      debugPrint('========== INITIAL SUMMARY DEBUG ==========');
      debugPrint('Initial Branch: ${existingSummary.branch?.id}');
      debugPrint('Selected Branch: ${selectedBranch?.id}');
      debugPrint('============================================');

      return;
    }

    final service = widget.service;
    final package = widget.package;
    final scheduledDate = widget.scheduledDate;
    final timeSlot = widget.timeSlot;

    final branch =
        widget.branch ?? context.read<BranchProvider>().selectedBranch;

    debugPrint('========== SUMMARY INIT DEBUG ==========');
    debugPrint('Widget Branch ID: ${widget.branch?.id}');
    debugPrint(
      'Provider Branch ID: '
          '${context.read<BranchProvider>().selectedBranch?.id}',
    );
    debugPrint('Final Branch ID: ${branch?.id}');
    debugPrint('Package ID: ${package?.id ?? "No package selected"}');
    debugPrint('=========================================');

    // Package is optional. Service, date and time are still required.
    if (service != null &&
        scheduledDate != null &&
        timeSlot != null) {
      provider.loadSummary(
        service: service,
        package: package,
        address: widget.address,
        branch: branch,
        date: scheduledDate,
        timeSlot: timeSlot,
      );
    }
  }

  Future<void> _handleEditBranch() async {
    final updatedBranch = await Navigator.of(context).push<BranchModel>(
      MaterialPageRoute(
        builder: (_) =>
        const BranchSelectionScreen(isSelectionMode: true),
      ),
    );

    if (updatedBranch != null && mounted) {
      context.read<BookingSummaryProvider>().updateBranch(updatedBranch);
    }
  }

  Future<void> _handleEditSchedule(
      BookingSummaryModel summary,
      ) async {
    final branch = summary.branch ??
        context.read<BranchProvider>().selectedBranch;

    debugPrint('========== EDIT SCHEDULE DEBUG ==========');
    debugPrint('Summary Branch: ${summary.branch?.name}');
    debugPrint('Summary Branch ID: ${summary.branch?.id}');
    debugPrint(
      'Provider Branch: '
          '${context.read<BranchProvider>().selectedBranch?.id}',
    );
    debugPrint('Final Branch ID: ${branch?.id}');
    debugPrint('==========================================');

    if (branch == null || branch.id.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a salon branch first.'),
        ),
      );
      return;
    }

    // Always pass service and branch details.
    // Package details are passed only when a package exists.
    final Map<String, dynamic> routeArguments = {
      'serviceId': summary.service.id,
      'serviceName': summary.service.name,
      'branchId': branch.id,
    };

    if (summary.package != null) {
      routeArguments['packageId'] = summary.package!.id;
      routeArguments['packageName'] = summary.package!.name;
    }

    final updatedSchedule = await Navigator.of(context).pushNamed(
      AppRoutes.dateTimeSelection,
      arguments: routeArguments,
    );

    if (updatedSchedule is Map<String, dynamic> && mounted) {
      final date = updatedSchedule['selectedDate'] as ServiceDateModel?;
      final slot =
      updatedSchedule['selectedTimeSlot'] as TimeSlotModel?;

      if (date != null && slot != null) {
        context
            .read<BookingSummaryProvider>()
            .updateSchedule(date, slot);
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
          // Loading State
          if (summaryProvider.isLoading) {
            return const Center(
              child: AppLoadingIndicator(),
            );
          }

          // Error State
          if (summaryProvider.hasError) {
            return AppErrorView(
              message: summaryProvider.errorMessage ??
                  "Couldn't load appointment summary",
              onRetry: _initializeSummary,
            );
          }

          final summary = summaryProvider.summary;

          // Incomplete State
          if (summary == null || !summary.isValid) {
            return AppEmptyState(
              title: 'Booking Details Incomplete',
              subtitle:
              'Some required booking information is missing. '
                  'Please complete all previous steps before reviewing '
                  'the summary.',
              actionText: 'Go Back',
              onActionPressed: () =>
                  Navigator.of(context).maybePop(),
            );
          }

          // Valid Appointment Summary Review
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
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

                // Salon Branch Location Card
                if (summary.branch != null)
                  SummaryBranchCard(
                    branch: summary.branch!,
                    onEdit: _handleEditBranch,
                  )
                else
                  AppEmptyState(
                    title: 'Salon branch not selected',
                    subtitle:
                    'Please select a salon branch before continuing.',
                    actionText: 'Select Branch',
                    onActionPressed: _handleEditBranch,
                  ),
                const SizedBox(height: 16),

                // Coupon Card
                SummaryCouponCard(
                  appliedCoupon: summary.appliedCoupon,
                  onApplyCoupon: (code) {
                    try {
                      final offerProv =
                      Provider.of<OfferProvider>(
                        context,
                        listen: false,
                      );

                      // Use service starting price when package is absent.
                      final bookingPrice = summary.package?.price ??
                          summary.service.startingPrice;

                      final coupon = offerProv.validateCoupon(
                        code,
                        bookingPrice,
                      );

                      if (coupon != null) {
                        summaryProvider.applyCoupon(coupon);
                      }
                    } catch (e) {
                      debugPrint('Coupon validation error: $e');
                    }
                  },
                  onRemoveCoupon: () {
                    summaryProvider.removeCoupon();
                  },
                  errorMessage: summaryProvider.couponError,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1.0,
            ),
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
              // Price Summary
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
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

              // Proceed CTA
              Expanded(
                flex: 6,
                child: AppButton(
                  text: 'Continue to Payment',
                  onPressed: () {
                    final currentSummary =
                        summaryProvider.summary;

                    if (currentSummary != null) {
                      _handleProceedToPayment(currentSummary);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}
