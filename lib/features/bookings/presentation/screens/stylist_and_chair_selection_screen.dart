import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../../branches/data/models/chair_availability_model.dart';
import '../../../branches/presentation/providers/branch_provider.dart';
import '../../../date_time/data/models/service_date_model.dart';
import '../../../date_time/data/models/time_slot_model.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/data/models/service_package_model.dart';
import '../../../services/data/models/service_products_response.dart';
import '../../../stylists/data/models/stylist_model.dart';
import '../../../stylists/presentation/providers/stylist_provider.dart';

class StylistAndChairSelectionScreen extends StatefulWidget {
  final ServiceModel service;
  final ServicePackageModel? package;
  final BranchModel? branch;
  final String branchId;
  final ServiceDateModel scheduledDate;
  final TimeSlotModel timeSlot;
  final String? productId;
  final ConsumableProduct? selectedProduct;

  const StylistAndChairSelectionScreen({
    super.key,
    required this.service,
    this.package,
    this.branch,
    required this.branchId,
    required this.scheduledDate,
    required this.timeSlot,
    this.productId,
    this.selectedProduct,
  });

  @override
  State<StylistAndChairSelectionScreen> createState() =>
      _StylistAndChairSelectionScreenState();
}

class _StylistAndChairSelectionScreenState
    extends State<StylistAndChairSelectionScreen> {
  StylistModel _selectedStylist = StylistModel.anyStylist;
  String? _selectedChairNumber; // null means 'Auto-Assign'
  ChairAvailabilityModel? _chairAvailability;
  bool _isLoadingChairs = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  String get _formattedDateString =>
      AppFormatters.formatBackendDate(widget.scheduledDate.date);

  int get _serviceDurationMinutes => AppFormatters.parseDurationMinutes(
    widget.package?.duration ?? widget.service.duration,
  );

  Future<void> _loadData() async {
    setState(() => _isLoadingChairs = true);

    // 1. Load chair availability
    final branchProv = context.read<BranchProvider>();
    final availability = await branchProv.checkChairAvailability(
      branchId: widget.branchId,
      date: _formattedDateString,
      timeSlot: widget.timeSlot.bookingTimeSlot,
      duration: _serviceDurationMinutes,
    );

    if (mounted) {
      setState(() {
        _chairAvailability = availability;
        _isLoadingChairs = false;
      });
    }

    // 2. Load stylists
    if (mounted) {
      final stylistProv = context.read<StylistProvider>();
      await stylistProv.loadStylists(
        branchId: widget.branchId,
        serviceId: widget.service.id,
        date: _formattedDateString,
        timeSlot: widget.timeSlot.bookingTimeSlot,
      );
    }
  }

  void _handleContinue() {
    Navigator.of(context).pushNamed(
      AppRoutes.bookingSummary,
      arguments: {
        'service': widget.service,
        'package': widget.package,
        'branch': widget.branch,
        'branchId': widget.branchId,
        'scheduledDate': widget.scheduledDate,
        'timeSlot': widget.timeSlot,
        'productId': widget.productId,
        'selectedProduct': widget.selectedProduct,
        'stylistId': _selectedStylist.id,
        'stylistName': _selectedStylist.name,
        'chairNumber': _selectedChairNumber,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stylistProv = context.watch<StylistProvider>();
    final stylists = stylistProv.stylists;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Stylist & Chair',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Context Summary Banner
            _buildAppointmentContextCard(),
            const SizedBox(height: 20),

            // Section 1: Chair Selection
            _buildChairSection(),
            const SizedBox(height: 24),

            // Section 2: Hairstylist Selection
            _buildStylistSection(stylistProv, stylists),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppointmentContextCard() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.scheduledDate.dayName}, ${widget.scheduledDate.dayNumber} ${widget.scheduledDate.monthName} • ${widget.timeSlot.formattedLabel}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChairSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Chair Station',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_chairAvailability != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _chairAvailability!.availableChairs > 0
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_chairAvailability!.availableChairs} of ${_chairAvailability!.totalChairs} Available',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _chairAvailability!.availableChairs > 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your preferred salon chair or let us auto-assign one for you.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        if (_isLoadingChairs)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: AppLoadingIndicator()),
          )
        else
          _buildChairGrid(),
      ],
    );
  }

  Widget _buildChairGrid() {
    final chairs = _chairAvailability?.chairs ?? [];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Auto-assign option chip
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: _selectedChairNumber == null
                    ? Colors.white
                    : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Auto-Assign',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _selectedChairNumber == null
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          selected: _selectedChairNumber == null,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _selectedChairNumber == null
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedChairNumber = null);
            }
          },
        ),

        // Real individual chairs from API
        ...chairs.map((chair) {
          final isSelected = _selectedChairNumber == chair.chairNumber;
          final isAvail = chair.isAvailable;

          return ChoiceChip(
            avatar: Icon(
              Icons.chair_alt_rounded,
              size: 16,
              color: !isAvail
                  ? AppColors.textTertiary
                  : isSelected
                  ? Colors.white
                  : AppColors.primary,
            ),
            label: Text(
              chair.chairNumber,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: !isAvail
                    ? AppColors.textTertiary
                    : isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: !isAvail
                ? AppColors.borderSubtle
                : AppColors.surface,
            disabledColor: AppColors.borderSubtle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: !isAvail
                    ? AppColors.borderSubtle
                    : isSelected
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            onSelected: isAvail
                ? (selected) {
                    setState(() {
                      _selectedChairNumber = selected
                          ? chair.chairNumber
                          : null;
                    });
                  }
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildStylistSection(
    StylistProvider stylistProv,
    List<StylistModel> stylists,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Hairstylist',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a dedicated professional or choose any available stylist for instant confirmation.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Default 'Any Available Stylist' card
        _buildStylistCard(
          stylist: StylistModel.anyStylist,
          isSelected: _selectedStylist.id == 'any',
          isAnyAvailable: true,
        ),
        const SizedBox(height: 10),

        if (stylistProv.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: AppLoadingIndicator()),
          )
        else ...[
          // List of real branch stylists
          ...stylists.map((stylist) {
            final isSelected = _selectedStylist.id == stylist.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildStylistCard(
                stylist: stylist,
                isSelected: isSelected,
                isAnyAvailable: false,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStylistCard({
    required StylistModel stylist,
    required bool isSelected,
    required bool isAnyAvailable,
  }) {
    return AppCard(
      onTap: () {
        setState(() => _selectedStylist = stylist);
      },
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      backgroundColor: isSelected
          ? AppColors.primaryLight.withValues(alpha: 0.3)
          : AppColors.surface,
      border: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1.0,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: isSelected
                ? AppColors.primary
                : AppColors.primaryLight,
            child: isAnyAvailable
                ? Icon(
                    Icons.people_outline_rounded,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 24,
                  )
                : (stylist.imageUrl != null && stylist.imageUrl!.isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      stylist.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildInitials(stylist.name),
                    ),
                  )
                : _buildInitials(stylist.name),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stylist.name,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isAnyAvailable)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            stylist.rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  stylist.role,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (stylist.specializations.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: stylist.specializations.take(3).map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          spec,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Radio / Checkmark
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isSelected ? AppColors.primary : AppColors.border,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String name) {
    final clean = name.trim();
    final initials = clean.isNotEmpty
        ? clean
              .split(' ')
              .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
              .take(2)
              .join()
        : 'ST';
    return Text(
      initials,
      style: AppTypography.titleSmall.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
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
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedChairNumber ?? 'Auto Chair',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _selectedStylist.name,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: AppButton(
                text: 'Continue to Review',
                onPressed: _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
