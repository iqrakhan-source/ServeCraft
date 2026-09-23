import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import '../../data/models/service_date_model.dart';

class DateSelectorWidget extends StatelessWidget {
  final List<ServiceDateModel> dates;
  final ServiceDateModel? selectedDate;
  final ValueChanged<ServiceDateModel> onDateSelected;

  const DateSelectorWidget({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = dates[index];
          final isSelected = selectedDate?.dateKey == item.dateKey;
          final isAvailable = item.isAvailable;

          return InkWell(
            onTap: isAvailable ? () => onDateSelected(item) : null,
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.45,
              child: Container(
                width: 68,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEEF2FF)
                      : (isAvailable
                          ? AppColors.surface
                          : AppColors.surfaceMuted),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x1A4F46E5),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day name (Today, Tomorrow, Fri, Sat...)
                    Text(
                      item.dayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable
                                ? AppColors.textSecondary
                                : AppColors.textTertiary),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Day number (25, 26...)
                    Text(
                      item.dayNumber,
                      style: AppTypography.titleLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textTertiary),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Month name (Sep, Oct...)
                    Text(
                      isAvailable ? item.monthName : 'Booked',
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable
                                ? AppColors.textSecondary
                                : AppColors.error),
                        fontWeight:
                            isAvailable ? FontWeight.w500 : FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
