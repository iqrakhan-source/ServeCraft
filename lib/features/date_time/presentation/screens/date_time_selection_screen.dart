
import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import 'package:prop_crm/core/widgets/app_error_view.dart';
import 'package:prop_crm/core/widgets/app_loading_indicator.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/branches/presentation/providers/branch_provider.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:prop_crm/features/services/presentation/providers/service_provider.dart';
import 'package:provider/provider.dart';

import '../providers/date_time_provider.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/time_slot_grid.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final String? serviceId;
  final String? serviceName;
  final String? packageId;
  final String? packageName;
  final String? branchId;

  const DateTimeSelectionScreen({
    super.key,
    this.serviceId,
    this.serviceName,
    this.packageId,
    this.packageName,
    this.branchId,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState
    extends State<DateTimeSelectionScreen> {
  bool get _isPickerMode {
    final args = ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>?;
    return args?['isPickerMode'] as bool? ?? false;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final args = ModalRoute.of(context)?.settings.arguments
      as Map<String, dynamic>? ?? {};

      final branchProvider = context.read<BranchProvider>();
      final selectedBranch = branchProvider.selectedBranch;

      final branchId = selectedBranch?.id ??
          widget.branchId ??
          args['branchId'] as String?;

      final serviceId =
          widget.serviceId ?? args['serviceId'] as String?;

      final serviceName =
          widget.serviceName ?? args['serviceName'] as String?;

      final packageId =
          widget.packageId ?? args['packageId'] as String?;

      final packageName =
          widget.packageName ?? args['packageName'] as String?;

      debugPrint('========== DATE SCREEN INIT ==========');
      debugPrint('Selected Branch ID: ${selectedBranch?.id}');
      debugPrint('Widget Branch ID: ${widget.branchId}');
      debugPrint('Route Branch ID: ${args['branchId']}');
      debugPrint('Final Branch ID: $branchId');
      debugPrint('Service ID: $serviceId');
      debugPrint('Package ID: $packageId');
      debugPrint('======================================');

      if (branchId == null || branchId.trim().isEmpty) {
        debugPrint('[DATE TIME] Branch ID is missing.');
        return;
      }

      if (serviceId == null || serviceId.trim().isEmpty) {
        debugPrint('[DATE TIME] Service ID is missing.');
        return;
      }

      final dateTimeProvider = context.read<DateTimeProvider>();

      dateTimeProvider.initContext(
        serviceId: serviceId,
        serviceName: serviceName,
        packageId: packageId,
        packageName: packageName,
        branchId: branchId,
      );

      await dateTimeProvider.loadAvailableDates(forceRefresh: true);
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
        'No Selected Package';

    final pickerMode = _isPickerMode;
    final canContinue = dateTimeProvider.isSelectionComplete;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Select Date & Time'),
      body: Builder(
        builder: (context) {
          if (dateTimeProvider.datesState.isLoading ||
              dateTimeProvider.datesState.isInitial) {
            return _buildLoadingState();
          }

          if (dateTimeProvider.datesState.isError) {
            return AppErrorView(
              message: "Couldn't load available times",
              onRetry: () => dateTimeProvider.loadAvailableDates(
                forceRefresh: true,
              ),
            );
          }

          final dates = dateTimeProvider.availableDates;
          final selectedDate = dateTimeProvider.selectedDate;
          final timeSlots = dateTimeProvider.timeSlots;
          final selectedSlot = dateTimeProvider.selectedTimeSlot;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(14),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayPackageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  onDateSelected: dateTimeProvider.selectDate,
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          '${selectedDate.dayName}, '
                              '${selectedDate.dayNumber} '
                              '${selectedDate.monthName}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: dateTimeProvider.slotsState.isLoading
                      ? _buildSlotsLoadingGrid()
                      : TimeSlotGrid(
                    slots: timeSlots,
                    selectedSlot: selectedSlot,
                    onSlotSelected:
                    dateTimeProvider.selectTimeSlot,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                text: 'Continue',
                onPressed: canContinue
                    ? () {
                  if (pickerMode) {
                    Navigator.of(context).pop({
                      'selectedDate':
                      dateTimeProvider.selectedDate,
                      'selectedTimeSlot':
                      dateTimeProvider.selectedTimeSlot,
                    });
                    return;
                  }

                  final routeArgs = ModalRoute.of(context)
                      ?.settings.arguments
                  as Map<String, dynamic>? ?? {};

                  final branchProvider =
                  context.read<BranchProvider>();
                  final branch =
                      branchProvider.selectedBranch;

                  final finalBranchId =
                      branch?.id ??
                          widget.branchId ??
                          routeArgs['branchId'] as String?;

                  debugPrint(
                    '[DATE TIME] Final Branch ID: $finalBranchId',
                  );

                  if (finalBranchId == null ||
                      finalBranchId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select a salon branch again.',
                        ),
                      ),
                    );
                    return;
                  }

                  final serviceProvider =
                  context.read<ServiceProvider>();

                  final serviceId =
                      widget.serviceId ??
                          dateTimeProvider.serviceId;

                  if (serviceId == null || serviceId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select a service again.',
                        ),
                      ),
                    );
                    return;
                  }

                  final matchingServices =
                  serviceProvider.services
                      .where((s) => s.id == serviceId);

                  if (matchingServices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'The selected service could not be found. '
                              'Please select the service again.',
                        ),
                      ),
                    );
                    return;
                  }

                  final ServiceModel service =
                      matchingServices.first;

                  final packageId =
                      widget.packageId ??
                          dateTimeProvider.packageId;

                  final matchingPackages = service.packages
                      .where((p) => p.id == packageId);

                  final ServicePackageModel? selectedPackage =
                  matchingPackages.isNotEmpty
                      ? matchingPackages.first
                      : null;

                  debugPrint('========== BOOKING DEBUG ==========');
                  debugPrint('Service ID: ${service.id}');
                  debugPrint('Service Name: ${service.name}');
                  debugPrint(
                    'Package ID: ${selectedPackage?.id}',
                  );
                  debugPrint('Branch ID: $finalBranchId');
                  debugPrint('===================================');

                  Navigator.of(context).pushNamed(
                    AppRoutes.bookingSummary,
                    arguments: {
                      'service': service,
                      'package': selectedPackage,
                      'branch': branch,
                      'branchId': finalBranchId,
                      'scheduledDate':
                      dateTimeProvider.selectedDate,
                      'timeSlot':
                      dateTimeProvider.selectedTimeSlot,
                      'productId': routeArgs['productId'],
                      'selectedProduct':
                      routeArgs['selectedProduct'],
                    },
                  );
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(
            height: 68,
            width: double.infinity,
            borderRadius: 12,
          ),
          const SizedBox(height: 24),
          const AppSkeleton(height: 20, width: 120),
          const SizedBox(height: 12),
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
          const AppSkeleton(height: 20, width: 160),
          const SizedBox(height: 14),
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
