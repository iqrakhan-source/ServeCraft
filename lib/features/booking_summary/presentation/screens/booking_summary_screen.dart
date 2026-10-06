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
import '../../../branches/presentation/screens/branch_selection_screen.dart';
import '../../../date_time/data/models/service_date_model.dart';
import '../../../date_time/data/models/time_slot_model.dart';
import '../../../offers/presentation/providers/offer_provider.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/data/models/service_package_model.dart';
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

  const BookingSummaryScreen({
    super.key,
    this.service,
    this.package,
    this.address,
    this.branch,
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
    final provider = context.read<BookingSummaryProvider>();

    if (widget.initialSummary != null) {
      provider.setSummary(widget.initialSummary!);
      return;
    }

    final service = widget.service;
    final package = widget.package;
    final scheduledDate = widget.scheduledDate;
    final timeSlot = widget.timeSlot;

    if (service != null &&
        package != null &&
        scheduledDate != null &&
        timeSlot != null) {
      provider.loadSummary(
        service: service,
        package: package,
        address: widget.address,
        branch: widget.branch,
        date: scheduledDate,
        timeSlot: timeSlot,
      );
    }
  }

  Future<void> _handleEditBranch() async {
    final updatedBranch = await Navigator.of(context).push<BranchModel>(
      MaterialPageRoute(
        builder: (_) => const BranchSelectionScreen(isSelectionMode: true),
      ),
    );

    if (updatedBranch != null && mounted) {
      context.read<BookingSummaryProvider>().updateBranch(updatedBranch);
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
            return const Center(child: AppLoadingIndicator());
          }

          // 2. Error State
          if (summaryProvider.hasError) {
            return AppErrorView(
              message: summaryProvider.errorMessage ??
                  "Couldn't load appointment summary",
              onRetry: _initializeSummary,
            );
          }

          final summary = summaryProvider.summary;

          // 3. Incomplete State
          if (summary == null || !summary.isValid) {
            return AppEmptyState(
              title: 'Booking Details Incomplete',
              subtitle:
                  'Some required booking information is missing. Please complete all previous steps before reviewing the summary.',
              actionText: 'Go Back',
              onActionPressed: () => Navigator.of(context).maybePop(),
            );
          }

          // 4. Valid Appointment Summary Review
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

                // Salon Branch Location Card
                SummaryBranchCard(
                  branch: summary.branch ??
                      const BranchModel(
                        id: 'branch-1',
                        name: 'Downtown Luxury Lounge',
                        address: '104 Royal Palms, Downtown Luxury Avenue, Mumbai',
                        phone: '+91 98765 43210',
                        openingTime: '09:00',
                        closingTime: '21:00',
                        isActive: true,
                      ),
                  onEdit: _handleEditBranch,
                ),
                const SizedBox(height: 16),

                // Coupon Card
                SummaryCouponCard(
                  appliedCoupon: summary.appliedCoupon,
                  onApplyCoupon: (code) {
                    try {
                      final offerProv = Provider.of<OfferProvider>(context, listen: false);
                      final coupon = offerProv.validateCoupon(
                        code,
                        summary.package.price,
                      );
                      if (coupon != null) {
                        summaryProvider.applyCoupon(coupon);
                      }
                    } catch (_) {}
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
}
