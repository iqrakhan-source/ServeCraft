import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SalonNotificationModel>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<bool> markAsRead(String id) {
    return remoteDataSource.markAsRead(id);
  }
}
