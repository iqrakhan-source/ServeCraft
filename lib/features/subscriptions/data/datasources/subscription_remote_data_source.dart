
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';

import '../models/subscription_plan_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({
    String? branchId,
  });
}

class SubscriptionRemoteDataSourceImpl
    implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({
    String? branchId,
  }) async {
    final response = await apiClient.get<List<SubscriptionPlanModel>>(
      ApiConstants.subscriptionPlans,
      queryParameters: branchId != null && branchId.isNotEmpty
          ? {'branchId': branchId}
          : null,
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException(
            'Invalid subscription plans response',
          );
        }

        final plansJson = json['plans'];

        if (plansJson is! List) {
          throw const FormatException(
            'Subscription plans list not found',
          );
        }

        return plansJson.map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Invalid subscription plan item',
            );
          }

          return SubscriptionPlanModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        }).toList();
      },
    );

    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch subscription plans',
      );
    }

    return response.data ?? <SubscriptionPlanModel>[];
  }
}
