import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/time_slot_model.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlotModel> slots;
  final TimeSlotModel? selectedSlot;
  final ValueChanged<TimeSlotModel> onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  bool _isMorning(TimeSlotModel slot) {
    final start = slot.startTime.toLowerCase();
    if (start.contains('am')) return true;
    if (start.startsWith('12:')) return false;
    return false;
  }

  bool _isAfternoon(TimeSlotModel slot) {
    final start = slot.startTime.toLowerCase();
    if (start.contains('pm')) {
      if (start.startsWith('12:') ||
          start.startsWith('1:') ||
          start.startsWith('01:') ||
          start.startsWith('2:') ||
          start.startsWith('02:') ||
          start.startsWith('3:') ||
          start.startsWith('03:') ||
          start.startsWith('4:') ||
          start.startsWith('04:')) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 10),
            Text(
              'No slots available',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please choose another date.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final morningSlots = slots.where(_isMorning).toList();
    final afternoonSlots = slots.where(_isAfternoon).toList();
    final eveningSlots = slots
        .where((s) => !_isMorning(s) && !_isAfternoon(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend indicators
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(
                color: AppColors.surface,
                borderColor: AppColors.border,
                label: 'Available',
              ),
              _buildLegend(
                color: AppColors.primaryLight,
                borderColor: AppColors.primary,
                label: 'Selected',
              ),
              _buildLegend(
                color: AppColors.surfaceMuted,
                borderColor: AppColors.border,
                label: 'Unavailable',
                isFaded: true,
              ),
            ],
          ),
        ),

        // 1. Morning Group
        if (morningSlots.isNotEmpty) ...[
          _buildGroupHeader('Morning Slots', Icons.wb_sunny_outlined),
          const SizedBox(height: 10),
          _buildSlotsWrap(morningSlots),
          const SizedBox(height: 20),
        ],

        // 2. Afternoon Group
        if (afternoonSlots.isNotEmpty) ...[
          _buildGroupHeader('Afternoon Slots', Icons.light_mode_outlined),
          const SizedBox(height: 10),
          _buildSlotsWrap(afternoonSlots),
          const SizedBox(height: 20),
        ],

        // 3. Evening Group
        if (eveningSlots.isNotEmpty) ...[
          _buildGroupHeader('Evening Slots', Icons.nights_stay_outlined),
          const SizedBox(height: 10),
          _buildSlotsWrap(eveningSlots),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildLegend({
    required Color color,
    required Color borderColor,
    required String label,
    bool isFaded = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isFaded ? AppColors.textTertiary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsWrap(List<TimeSlotModel> groupSlots) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: groupSlots.map((slot) {
        final isSelected = selectedSlot?.id == slot.id;
        final isAvailable = slot.isAvailable;

        return InkWell(
          onTap: isAvailable ? () => onSlotSelected(slot) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 102,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isAvailable ? AppColors.surface : AppColors.surfaceMuted),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isAvailable
                        ? AppColors.border
                        : AppColors.borderSubtle),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Colors.white)
                    else if (!isAvailable)
                      const Icon(Icons.block_rounded,
                          size: 12, color: AppColors.textTertiary),
                    if (isSelected || !isAvailable) const SizedBox(width: 4),
                    Text(
                      slot.startTime,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textTertiary),
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable ? 'Available' : 'Booked',
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : (isAvailable
                            ? AppColors.success
                            : AppColors.textTertiary),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
