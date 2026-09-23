import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/presentation/providers/booking_summary_provider.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_amount_card.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/payment_security_note.dart';

class PaymentScreen extends StatefulWidget {
  final BookingSummaryModel? bookingSummary;

  const PaymentScreen({
    super.key,
    this.bookingSummary,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  void _initializePayment() {
    final paymentProvider = context.read<PaymentProvider>();

    BookingSummaryModel? summary = widget.bookingSummary;
    if (summary == null) {
      try {
        summary = context.read<BookingSummaryProvider>().summary;
      } catch (_) {}
    }

    if (summary != null) {
      paymentProvider.setBookingSummary(summary);
    }

    paymentProvider.loadPaymentMethods();
  }

  void _handleContinue() {
    final paymentProvider = context.read<PaymentProvider>();
    final summary = paymentProvider.bookingSummary;
    final selectedMethod = paymentProvider.selectedMethod;

    if (!paymentProvider.isSelectionValid || summary == null || selectedMethod == null) {
      return;
    }

    _showPaymentReviewSheet(context, summary, selectedMethod);
  }

  void _showPaymentReviewSheet(
    BuildContext context,
    BookingSummaryModel summary,
    PaymentMethodModel selectedMethod,
  ) {
    final bookingProvider = context.read<BookingProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !bookingProvider.isCreating,
      enableDrag: !bookingProvider.isCreating,
      builder: (bottomSheetContext) {
        return ChangeNotifierProvider<BookingProvider>.value(
          value: bookingProvider,
          child: Consumer<BookingProvider>(
            builder: (ctx, bp, _) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        'Review & Confirm Booking',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary recap tile
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    summary.service.name,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  summary.package.name,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      summary.timeSlot.formattedLabel,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.payment_outlined,
                                      size: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      selectedMethod.title,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 16, color: AppColors.border),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payable Amount',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  AppFormatters.formatCurrency(
                                      summary.pricing.totalAmount),
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error message if any
                      if (bp.hasError && bp.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  bp.errorMessage!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // CTA Confirm Button
                      AppButton(
                        text: bp.hasError ? 'Retry' : 'Confirm Booking',
                        isLoading: bp.isCreating,
                        onPressed: bp.isCreating
                            ? null
                            : () async {
                                final booking = await bp.createBooking(
                                  summary: summary,
                                  paymentMethod: selectedMethod,
                                );

                                if (booking != null && context.mounted) {
                                  Navigator.of(bottomSheetContext).pop();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.bookingConfirmation,
                                    (route) =>
                                        route.settings.name ==
                                            AppRoutes.mainNav ||
                                        route.isFirst,
                                    arguments: {'booking': booking},
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final summary = paymentProvider.bookingSummary;
    final payableAmount = paymentProvider.payableAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Payment',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Builder(
            builder: (context) {
              // 1. Loading state
              if (paymentProvider.isLoading) {
                return _buildLoadingState();
              }

              // 2. Error state
              if (paymentProvider.hasError) {
                return AppErrorView(
                  message: paymentProvider.errorMessage ??
                      "Couldn't load payment options",
                  onRetry: () =>
                      paymentProvider.loadPaymentMethods(forceRefresh: true),
                );
              }

              // 3. Fallback when booking summary is completely missing
              if (summary == null || payableAmount <= 0) {
                return _buildIncompleteState();
              }

              final methods = paymentProvider.paymentMethods;
              final selectedMethod = paymentProvider.selectedMethod;

              // 4. Main Payment Selection Content
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Card
                    PaymentAmountCard(
                      amount: payableAmount,
                      serviceName: summary.service.name,
                      packageName: summary.package.name,
                    ),
                    const SizedBox(height: 24),

                    // Section Heading
                    Text(
                      'Select Payment Method',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method List
                    ...methods.map((method) {
                      final isSelected = selectedMethod?.id == method.id;
                      return PaymentMethodTile(
                        method: method,
                        isSelected: isSelected,
                        onTap: () =>
                            paymentProvider.selectPaymentMethod(method),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Security Reassurance Note
                    const PaymentSecurityNote(),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      // Sticky Bottom CTA Bar
      bottomNavigationBar: paymentProvider.payableAmount > 0
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
                    // Payable Amount Summary
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total to Pay',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(payableAmount),
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
                        text: 'Continue',
                        onPressed: paymentProvider.isSelectionValid
                            ? _handleContinue
                            : null,
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
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Payable Amount',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please complete the booking summary review before selecting a payment method.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Return to Summary',
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
          // Amount Card skeleton
          AppSkeleton(height: 96, width: double.infinity, borderRadius: 14),
          SizedBox(height: 24),

          // Heading skeleton
          AppSkeleton(height: 20, width: 180, borderRadius: 6),
          SizedBox(height: 14),

          // Method tiles skeleton
          AppSkeleton(height: 72, width: double.infinity, borderRadius: 12),
          SizedBox(height: 12),
          AppSkeleton(height: 72, width: double.infinity, borderRadius: 12),
          SizedBox(height: 12),
          AppSkeleton(height: 72, width: double.infinity, borderRadius: 12),
          SizedBox(height: 16),

          // Security note skeleton
          AppSkeleton(height: 56, width: double.infinity, borderRadius: 10),
        ],
      ),
    );
  }
}
