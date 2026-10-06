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
    await Future.delayed(const Duration(milliseconds: 100));

    return const [
      PaymentMethodModel(
        id: 'pm_online',
        title: 'Online Payment',
        subtitle: 'Pay now via UPI (GPay, PhonePe, Paytm), Credit/Debit Card or Net Banking',
        type: PaymentMethodType.upi,
        isAvailable: true,
      ),
      PaymentMethodModel(
        id: 'pm_salon',
        title: 'Pay at Salon',
        subtitle: 'Pay at front desk reception after your appointment (Cash, Card, or UPI)',
        type: PaymentMethodType.cod,
        isAvailable: true,
      ),
    ];
  }
}
