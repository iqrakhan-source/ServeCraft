import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<SalonNotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      const SalonNotificationModel(
        id: 'notif_1',
        title: 'Appointment Confirmed',
        message:
            'Your appointment for Executive Haircut & Styling at Downtown Luxury Lounge is confirmed for tomorrow at 11:00 AM.',
        timestamp: '15m ago',
        type: NotificationType.bookingConfirmed,
        isRead: false,
        appointmentId: 'LX-2026-0042',
      ),
      const SalonNotificationModel(
        id: 'notif_2',
        title: 'Senior Stylist Assigned',
        message:
            'Senior Master Stylist Vikram has been assigned to your appointment at Downtown Luxury Lounge.',
        timestamp: '1h ago',
        type: NotificationType.appointmentAccepted,
        isRead: false,
        appointmentId: 'LX-2026-0042',
      ),
      const SalonNotificationModel(
        id: 'notif_3',
        title: 'Weekend Spa Special: 20% OFF',
        message:
            'Indulge in Moroccan Argan Hair Spa and Hydra Medi-Facials this weekend. Use code RELAX500 at checkout.',
        timestamp: '4h ago',
        type: NotificationType.offerPromo,
        isRead: false,
      ),
      const SalonNotificationModel(
        id: 'notif_4',
        title: 'Appointment Rescheduled',
        message:
            'Your appointment #LX-2026-0038 was successfully rescheduled to Friday, Oct 14 at 2:00 PM.',
        timestamp: '1d ago',
        type: NotificationType.appointmentRescheduled,
        isRead: true,
        appointmentId: 'LX-2026-0038',
      ),
      const SalonNotificationModel(
        id: 'notif_5',
        title: 'Slot Unavailable (Declined)',
        message:
            'Your request for Bridal Makeup on Oct 8 could not be accepted due to full stylist bookings. Please select an alternate slot.',
        timestamp: '3d ago',
        type: NotificationType.appointmentRejected,
        isRead: true,
      ),
      const SalonNotificationModel(
        id: 'notif_6',
        title: 'Appointment Completed',
        message:
            'Thank you for visiting Luxe Salon & Spa! We hope you loved your Hydra Medi-Facial & Glow session. Rate your experience.',
        timestamp: '4d ago',
        type: NotificationType.appointmentCompleted,
        isRead: true,
        appointmentId: 'LX-2026-0038',
      ),
      const SalonNotificationModel(
        id: 'notif_7',
        title: 'Appointment Cancelled',
        message:
            'Booking #LX-2026-0021 for Moroccan Argan Hair Spa was cancelled per your request. No cancellation fee was charged.',
        timestamp: '10d ago',
        type: NotificationType.appointmentCancelled,
        isRead: true,
        appointmentId: 'LX-2026-0021',
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => SalonNotificationModel(
                id: n.id,
                title: n.title,
                message: n.message,
                timestamp: n.timestamp,
                type: n.type,
                isRead: true,
                appointmentId: n.appointmentId,
              ))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  Widget _buildNotificationCard(SalonNotificationModel notif) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? AppColors.surface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.isRead
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notif.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notif.icon,
              size: 20,
              color: notif.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: notif.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notif.timestamp,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  notif.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (notif.appointmentId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID: ${notif.appointmentId}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!notif.isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Notifications',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You have no salon updates or messages right now.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
