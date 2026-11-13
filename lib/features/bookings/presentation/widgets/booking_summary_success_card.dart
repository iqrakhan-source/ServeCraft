import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utilities/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../booking_summary/data/models/booking_summary_model.dart';
import '../../data/models/create_booking_response_model.dart';

class BookingSummarySuccessCard extends StatelessWidget {
  final CreateBookingResponseModel booking;
  final BookingSummaryModel summary;

  const BookingSummarySuccessCard({
    super.key,
    required this.booking,
    required this.summary,
  });

  String _formatPaymentMethodName(String method) {
    final lower = method.toLowerCase().trim();
    if (lower.contains('cash') ||
        lower.contains('salon') ||
        lower.contains('cod') ||
        lower.contains('offline')) {
      return 'Pay at Salon';
    }
    if (lower.contains('upi')) {
      return 'UPI Payment';
    }
    if (lower.contains('card')) {
      return 'Credit / Debit Card';
    }
    return 'Online Payment';
  }

  IconData _getPaymentIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('online') || value.contains('gateway')) {
      return Icons.payment_rounded;
    }

    if (value.contains('upi')) {
      return Icons.qr_code_2_rounded;
    }

    if (value.contains('card')) {
      return Icons.credit_card_rounded;
    }

    return Icons.storefront_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final appointment = booking.appointment;
    final packageName = summary.package?.name ?? 'Standard Service';

    return AppCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service and package
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
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
                      summary.service.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      packageName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // Appointment schedule
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Appointment Date',
            value: appointment.date,
          ),
          const SizedBox(height: 12),

          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Time Slot',
            value: appointment.timeSlot,
          ),
          const SizedBox(height: 12),

          _buildDetailRow(
            icon: Icons.timelapse_rounded,
            label: 'Duration',
            value: '${appointment.totalDuration} minutes',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // Branch
          _buildDetailRow(
            icon: Icons.storefront_rounded,
            label: 'Salon Branch',
            value: appointment.branchName,
          ),

          if (appointment.stylistName != null &&
              appointment.stylistName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Stylist',
              value: appointment.stylistName!,
            ),
          ],

          if (appointment.chairNumber != null &&
              appointment.chairNumber!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.event_seat_outlined,
              label: 'Chair',
              value: appointment.chairNumber!,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // Payment method and total
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(appointment.paymentMethod),
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Mode',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            _formatPaymentMethodName(appointment.paymentMethod),
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Status: ${appointment.paymentStatus.toUpperCase()}',
                            style: AppTypography.labelSmall.copyWith(
                              color:
                                  appointment.paymentStatus.toLowerCase() ==
                                      'paid'
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(appointment.totalAmount),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
