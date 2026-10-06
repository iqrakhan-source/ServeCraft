import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../offers/data/models/coupon_model.dart';
import '../../../offers/presentation/screens/offers_screen.dart';

class SummaryCouponCard extends StatefulWidget {
  final CouponModel? appliedCoupon;
  final Function(String code) onApplyCoupon;
  final VoidCallback onRemoveCoupon;
  final String? errorMessage;

  const SummaryCouponCard({
    super.key,
    this.appliedCoupon,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    this.errorMessage,
  });

  @override
  State<SummaryCouponCard> createState() => _SummaryCouponCardState();
}

class _SummaryCouponCardState extends State<SummaryCouponCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.appliedCoupon?.code ?? '');
  }

  @override
  void didUpdateWidget(covariant SummaryCouponCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appliedCoupon != oldWidget.appliedCoupon) {
      _controller.text = widget.appliedCoupon?.code ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCoupon = widget.appliedCoupon != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.confirmation_num_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Salon Offers & Coupons',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final selectedCoupon = await Navigator.of(context).push<CouponModel>(
                    MaterialPageRoute(
                      builder: (_) => const OffersScreen(isSelectionMode: true),
                    ),
                  );
                  if (selectedCoupon != null) {
                    widget.onApplyCoupon(selectedCoupon.code);
                  }
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'View Coupons',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (hasCoupon)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.appliedCoupon!.code} Applied!',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.appliedCoupon!.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: widget.onRemoveCoupon,
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code (e.g. GLOW20)',
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        widget.onApplyCoupon(_controller.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
