import '../../data/models/subscription_invoice_model.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/subscription_purchase_response_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({String? branchId});

  Future<SubscriptionPurchaseResponseModel> purchaseSubscription({
    required String planId,
    required String branchId,
    required String paymentMethod,
  });

  Future<List<SubscriptionInvoiceModel>> getSubscriptionInvoices();
}
