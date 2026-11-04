
import 'package:prop_crm/features/subscriptions/data/repositories/subscription_repository.dart';

import '../datasources/subscription_remote_data_source.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({
    String? branchId,
  }) {
    return remoteDataSource.getSubscriptionPlans(
      branchId: branchId,
    );
  }
}
