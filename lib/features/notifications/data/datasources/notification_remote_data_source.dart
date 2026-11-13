import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<SalonNotificationModel>> getNotifications();
  Future<bool> markAsRead(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SalonNotificationModel>> getNotifications() async {
    final response = await apiClient.get<List<SalonNotificationModel>>(
      ApiConstants.notifications,
      fromJson: (json) {
        dynamic listJson;

        if (json is List) {
          listJson = json;
        } else if (json is Map) {
          listJson = json['data'] ?? json['notifications'];
        }

        if (listJson is! List) {
          return <SalonNotificationModel>[];
        }

        return listJson
            .whereType<Map>()
            .map(
              (item) => SalonNotificationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      },
    );

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch notifications.',
      );
    }

    return response.data ?? <SalonNotificationModel>[];
  }

  @override
  Future<bool> markAsRead(String id) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.readNotification(id),
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    return response.success;
  }
}
