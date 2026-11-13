import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/subscription_invoice_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_purchase_response_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({String? branchId});

  Future<SubscriptionPurchaseResponseModel> purchaseSubscription({
    required String planId,
    required String branchId,
    required String paymentMethod,
  });

  Future<List<SubscriptionInvoiceModel>> getSubscriptionInvoices();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({required this.apiClient});

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
        dynamic plansJson;

        if (json is List) {
          plansJson = json;
        } else if (json is Map) {
          plansJson = json['data'] ?? json['plans'];
        }

        if (plansJson is! List) {
          return <SubscriptionPlanModel>[];
        }

        return plansJson
            .whereType<Map>()
            .map(
              (item) => SubscriptionPlanModel.fromJson(
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
            : 'Failed to fetch subscription plans',
      );
    }

    return response.data ?? <SubscriptionPlanModel>[];
  }

  @override
  Future<SubscriptionPurchaseResponseModel> purchaseSubscription({
    required String planId,
    required String branchId,
    required String paymentMethod,
  }) async {
    final response = await apiClient.post<SubscriptionPurchaseResponseModel>(
      ApiConstants.purchaseSubscription,
      data: {
        'planId': planId,
        'branchId': branchId,
        'paymentMethod': paymentMethod.toLowerCase(),
      },
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('Invalid subscription purchase response');
        }
        return SubscriptionPurchaseResponseModel.fromJson(
          Map<String, dynamic>.from(json),
        );
      },
    );

    if (!response.success || response.data == null) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to purchase subscription.',
      );
    }

    return response.data!;
  }

  @override
  Future<List<SubscriptionInvoiceModel>> getSubscriptionInvoices() async {
    final response = await apiClient.get<List<SubscriptionInvoiceModel>>(
      ApiConstants.subscriptionInvoices,
      fromJson: (json) {
        dynamic invoicesJson;

        if (json is List) {
          invoicesJson = json;
        } else if (json is Map) {
          invoicesJson = json['data'] ?? json['invoices'];
        }

        if (invoicesJson is! List) {
          return <SubscriptionInvoiceModel>[];
        }

        return invoicesJson
            .whereType<Map>()
            .map(
              (item) => SubscriptionInvoiceModel.fromJson(
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
            : 'Failed to fetch subscription invoices.',
      );
    }

    return response.data ?? <SubscriptionInvoiceModel>[];
  }
}
