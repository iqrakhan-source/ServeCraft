import '../../data/models/payment_method_model.dart';

abstract class PaymentRepository {
  Future<List<PaymentMethodModel>> getPaymentMethods();
}
