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

  SalonNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timestamp,
    NotificationType? type,
    bool? isRead,
    String? appointmentId,
  }) {
    return SalonNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      appointmentId: appointmentId ?? this.appointmentId,
    );
  }

  factory SalonNotificationModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? '').toString();
    final lowerTitle = title.toLowerCase();

    NotificationType type = NotificationType.bookingConfirmed;
    if (lowerTitle.contains('cancel')) {
      type = NotificationType.appointmentCancelled;
    } else if (lowerTitle.contains('reschedule')) {
      type = NotificationType.appointmentRescheduled;
    } else if (lowerTitle.contains('complete')) {
      type = NotificationType.appointmentCompleted;
    } else if (lowerTitle.contains('reject') ||
        lowerTitle.contains('decline')) {
      type = NotificationType.appointmentRejected;
    } else if (lowerTitle.contains('offer') ||
        lowerTitle.contains('promo') ||
        lowerTitle.contains('discount')) {
      type = NotificationType.offerPromo;
    } else if (lowerTitle.contains('assign') || lowerTitle.contains('accept')) {
      type = NotificationType.appointmentAccepted;
    }

    final rawCreated = json['createdAt']?.toString();
    String timeStr = 'Just now';
    if (rawCreated != null) {
      final parsed = DateTime.tryParse(rawCreated);
      if (parsed != null) {
        final diff = DateTime.now().difference(parsed);
        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes.clamp(1, 59)}m ago';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}h ago';
        } else {
          timeStr = '${diff.inDays}d ago';
        }
      }
    }

    return SalonNotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: title,
      message: (json['message'] ?? '').toString(),
      timestamp: timeStr,
      type: type,
      isRead: json['isRead'] as bool? ?? false,
      appointmentId: (json['appointmentId'] ?? json['appointment']?['_id'])
          ?.toString(),
    );
  }

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
