import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationProvider({required this.repository});

  ViewState<List<SalonNotificationModel>> _notificationsState =
      ViewState.initial();
  ViewState<List<SalonNotificationModel>> get notificationsState =>
      _notificationsState;
  List<SalonNotificationModel> get notifications =>
      _notificationsState.data ?? [];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _notificationsState = ViewState.loading();
    notifyListeners();

    try {
      final data = await repository.getNotifications();
      _notificationsState = ViewState.success(data);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _notificationsState = ViewState.error(appError.message);
    }

    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    // Optimistic UI update
    final currentList = List<SalonNotificationModel>.from(notifications);
    final index = currentList.indexWhere((n) => n.id == id);
    if (index != -1 && !currentList[index].isRead) {
      currentList[index] = currentList[index].copyWith(isRead: true);
      _notificationsState = ViewState.success(currentList);
      notifyListeners();

      try {
        await repository.markAsRead(id);
      } catch (_) {
        // Silently handle background read failure
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    final currentList = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _notificationsState = ViewState.success(currentList);
    notifyListeners();

    for (final notif in unread) {
      try {
        await repository.markAsRead(notif.id);
      } catch (_) {}
    }
  }
}
