import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/payment_method_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await apiService.get(ApiConstants.paymentMethods);
    final data = response.data;
    if (data is List) {
      return data
          .map((item) =>
              PaymentMethodModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class MockPaymentRemoteDataSource implements PaymentRemoteDataSource {
  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 150));

    return const [
      PaymentMethodModel(
        id: 'pm_upi',
        title: 'UPI',
        subtitle: 'Pay using any UPI app',
        type: PaymentMethodType.upi,
        isAvailable: true,
      ),
      PaymentMethodModel(
        id: 'pm_card',
        title: 'Credit / Debit Card',
        subtitle: 'Credit or debit card',
        type: PaymentMethodType.card,
        isAvailable: true,
      ),
      PaymentMethodModel(
        id: 'pm_cod',
        title: 'Cash on Delivery',
        subtitle: 'Pay after service completion',
        type: PaymentMethodType.cod,
        isAvailable: true,
      ),
    ];
  }
}
