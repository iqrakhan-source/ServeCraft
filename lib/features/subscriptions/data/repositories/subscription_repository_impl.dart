import '../datasources/subscription_remote_data_source.dart';
import '../models/subscription_invoice_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_purchase_response_model.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({String? branchId}) {
    return remoteDataSource.getSubscriptionPlans(branchId: branchId);
  }

  @override
  Future<SubscriptionPurchaseResponseModel> purchaseSubscription({
    required String planId,
    required String branchId,
    required String paymentMethod,
  }) {
    return remoteDataSource.purchaseSubscription(
      planId: planId,
      branchId: branchId,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<List<SubscriptionInvoiceModel>> getSubscriptionInvoices() {
    return remoteDataSource.getSubscriptionInvoices();
  }
}
