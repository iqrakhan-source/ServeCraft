import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../providers/date_time_provider.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/time_slot_grid.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final String? serviceId;
  final String? serviceName;
  final String? packageId;
  final String? packageName;

  const DateTimeSelectionScreen({
    super.key,
    this.serviceId,
    this.serviceName,
    this.packageId,
    this.packageName,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DateTimeProvider>();
      provider.initContext(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        packageId: widget.packageId,
        packageName: widget.packageName,
      );
      provider.loadAvailableDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeProvider = context.watch<DateTimeProvider>();

    final displayServiceName = widget.serviceName ??
        dateTimeProvider.serviceName ??
        'Home Service';
    final displayPackageName = widget.packageName ??
        dateTimeProvider.packageName ??
        'Selected Package';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Select Date & Time',
      ),
      body: Builder(
        builder: (context) {
          if (dateTimeProvider.datesState.isLoading ||
              dateTimeProvider.datesState.isInitial) {
            return _buildLoadingState();
          }

          if (dateTimeProvider.datesState.isError) {
            return AppErrorView(
              message: "Couldn't load available times",
              onRetry: () =>
                  dateTimeProvider.loadAvailableDates(forceRefresh: true),
            );
          }

          final dates = dateTimeProvider.availableDates;
          final selectedDate = dateTimeProvider.selectedDate;
          final timeSlots = dateTimeProvider.timeSlots;
          final selectedSlot = dateTimeProvider.selectedTimeSlot;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Service Summary Context Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: AppCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.home_repair_service_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayServiceName,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayPackageName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
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
                ),
                const SizedBox(height: 24),

                // 2. Date Selection Header & Horizontal Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Select a date',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DateSelectorWidget(
                  dates: dates,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    dateTimeProvider.selectDate(date);
                  },
                ),
                const SizedBox(height: 28),

                // 3. Time Slots Header & Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available time slots',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (selectedDate != null)
                        Text(
                          '${selectedDate.dayName}, ${selectedDate.dayNumber} ${selectedDate.monthName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: dateTimeProvider.slotsState.isLoading
                      ? _buildSlotsLoadingGrid()
                      : TimeSlotGrid(
                          slots: timeSlots,
                          selectedSlot: selectedSlot,
                          onSlotSelected: (slot) {
                            dateTimeProvider.selectTimeSlot(slot);
                          },
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),

      // Sticky Bottom CTA
      bottomNavigationBar: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                text: 'Continue',
                onPressed: dateTimeProvider.isSelectionComplete
                    ? () {
                        // Return/establish appointment state for upcoming checkout
                        Navigator.of(context).pop({
                          'selectedDate': dateTimeProvider.selectedDate,
                          'selectedTimeSlot': dateTimeProvider.selectedTimeSlot,
                        });
                      }
                    : null,
              ),
              if (!dateTimeProvider.isSelectionComplete) ...[
                const SizedBox(height: 6),
                Text(
                  dateTimeProvider.selectedDate == null
                      ? 'Please select a date to continue'
                      : 'Please select an available time slot',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary skeleton
          const AppSkeleton(
            height: 68,
            width: double.infinity,
            borderRadius: 12,
          ),
          const SizedBox(height: 24),

          // Date header skeleton
          const AppSkeleton(height: 20, width: 120),
          const SizedBox(height: 12),

          // Horizontal dates skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const AppSkeleton(
                height: 98,
                width: 68,
                borderRadius: 12,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Time slot header skeleton
          const AppSkeleton(height: 20, width: 160),
          const SizedBox(height: 14),

          // Slots grid skeleton
          _buildSlotsLoadingGrid(),
        ],
      ),
    );
  }

  Widget _buildSlotsLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        return const AppSkeleton(
          height: double.infinity,
          width: double.infinity,
          borderRadius: 10,
        );
      },
    );
  }
}
