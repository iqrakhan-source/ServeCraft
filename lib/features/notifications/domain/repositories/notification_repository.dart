import 'package:prop_crm/features/notifications/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<SalonNotificationModel>> getNotifications();
  Future<bool> markAsRead(String id);
}
