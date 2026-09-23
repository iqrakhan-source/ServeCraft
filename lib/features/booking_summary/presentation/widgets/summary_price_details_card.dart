import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/widgets/app_card.dart';
import '../../data/models/pricing_breakdown_model.dart';

class SummaryPriceDetailsCard extends StatelessWidget {
  final PricingBreakdown pricing;

  const SummaryPriceDetailsCard({
    super.key,
    required this.pricing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Price Details',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Package Price Row
          _buildPriceRow(
            label: 'Package Price',
            amount: AppFormatters.formatCurrency(pricing.packagePrice),
          ),

          // 2. Discount Row (if applied)
          if (pricing.hasDiscount) ...[
            const SizedBox(height: 10),
            _buildPriceRow(
              label: 'Discount',
              amount: '-${AppFormatters.formatCurrency(pricing.discount)}',
              isDiscount: true,
            ),
          ],

          const SizedBox(height: 10),

          // 3. Taxes Row
          _buildPriceRow(
            label: 'Taxes & Fees',
            subLabel: 'Standard ${(pricing.taxRate * 100).toInt()}% GST',
            amount: AppFormatters.formatCurrency(pricing.taxAmount),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 4. Total Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(pricing.totalAmount),
                style: AppTypography.priceLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Reassurance Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Free cancellation up to 2 hours before scheduled slot',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    String? subLabel,
    required String amount,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDiscount ? AppColors.success : AppColors.textSecondary,
                fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
        Text(
          amount,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
