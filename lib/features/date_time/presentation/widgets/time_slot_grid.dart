import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot?.id == slot.id;
        final isAvailable = slot.isAvailable;

        return InkWell(
          onTap: isAvailable ? () => onSlotSelected(slot) : null,
          borderRadius: BorderRadius.circular(10),
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEEF2FF)
                    : (isAvailable ? AppColors.surface : AppColors.surfaceMuted),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x1A4F46E5),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : (isAvailable
                            ? Icons.schedule_rounded
                            : Icons.block_rounded),
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : (isAvailable
                            ? AppColors.textSecondary
                            : AppColors.textTertiary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slot.formattedLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textTertiary),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
