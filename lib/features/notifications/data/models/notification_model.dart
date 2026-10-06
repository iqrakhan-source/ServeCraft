import 'package:flutter/material.dart';

enum NotificationType {
  bookingConfirmed,
  appointmentAccepted,
  appointmentRejected,
  appointmentRescheduled,
  appointmentCancelled,
  appointmentCompleted,
  offerPromo,
}

class SalonNotificationModel {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationType type;
  final bool isRead;
  final String? appointmentId;

  const SalonNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.appointmentId,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.calendar_today_rounded;
      case NotificationType.appointmentAccepted:
        return Icons.verified_rounded;
      case NotificationType.appointmentRejected:
        return Icons.event_busy_rounded;
      case NotificationType.appointmentRescheduled:
        return Icons.update_rounded;
      case NotificationType.appointmentCancelled:
        return Icons.cancel_outlined;
      case NotificationType.appointmentCompleted:
        return Icons.spa_rounded;
      case NotificationType.offerPromo:
        return Icons.local_offer_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return const Color(0xFF8B5A42);
      case NotificationType.appointmentAccepted:
        return const Color(0xFF16A34A);
      case NotificationType.appointmentRejected:
        return const Color(0xFFDC2626);
      case NotificationType.appointmentRescheduled:
        return const Color(0xFFD97706);
      case NotificationType.appointmentCancelled:
        return const Color(0xFFDC2626);
      case NotificationType.appointmentCompleted:
        return const Color(0xFF16A34A);
      case NotificationType.offerPromo:
        return const Color(0xFFB88E58);
    }
  }
}
