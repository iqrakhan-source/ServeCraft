import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    this.onTap,
  });

  IconData _getIconForType(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.upi:
        return Icons.qr_code_2_rounded;
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
      case PaymentMethodType.cod:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = method.isAvailable;
    final iconData = _getIconForType(method.type);

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF2FF) // Indigo 50 subtle tint
              : (isAvailable ? AppColors.surface : AppColors.surfaceMuted),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  // Payment Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isAvailable
                              ? AppColors.primaryLight
                              : AppColors.surfaceMuted),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      size: 22,
                      color: isSelected
                          ? Colors.white
                          : (isAvailable
                              ? AppColors.primary
                              : AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.title,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: isAvailable
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Custom Radio Selection Indicator
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvailable
                                ? AppColors.border
                                : AppColors.textTertiary.withAlpha(80)),
                        width: isSelected ? 6.5 : 2.0,
                      ),
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
