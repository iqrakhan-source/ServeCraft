import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/payment/data/repositories/payment_repository_impl.dart';

class CustomPaymentRemoteDataSource implements PaymentRemoteDataSource {
  final List<PaymentMethodModel> methods;

  CustomPaymentRemoteDataSource(this.methods);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    return methods;
  }
}

void main() {
  late MockPaymentRemoteDataSource dataSource;
  late PaymentRepositoryImpl repository;

  setUp(() {
    dataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(remoteDataSource: dataSource);
  });

  group('PaymentRepository Tests', () {
    test('getPaymentMethods returns standard options: UPI, Card, and COD',
        () async {
      final methods = await repository.getPaymentMethods();

      expect(methods.length, 3);
      expect(methods[0].type, PaymentMethodType.upi);
      expect(methods[0].title, 'UPI');
      expect(methods[0].isAvailable, isTrue);

      expect(methods[1].type, PaymentMethodType.card);
      expect(methods[1].title, 'Credit / Debit Card');
      expect(methods[1].isAvailable, isTrue);

      expect(methods[2].type, PaymentMethodType.cod);
      expect(methods[2].title, 'Cash on Delivery');
      expect(methods[2].isAvailable, isTrue);
    });

    test('Handles unavailable payment options correctly', () async {
      final customDs = CustomPaymentRemoteDataSource(const [
        PaymentMethodModel(
          id: 'pm_upi',
          title: 'UPI',
          subtitle: 'UPI App',
          type: PaymentMethodType.upi,
          isAvailable: true,
        ),
        PaymentMethodModel(
          id: 'pm_cod',
          title: 'Cash on Delivery',
          subtitle: 'Pay after service',
          type: PaymentMethodType.cod,
          isAvailable: false,
        ),
      ]);
      final customRepo = PaymentRepositoryImpl(remoteDataSource: customDs);

      final methods = await customRepo.getPaymentMethods();
      expect(methods.length, 2);
      expect(methods.any((m) => !m.isAvailable), isTrue);
      expect(methods.firstWhere((m) => m.type == PaymentMethodType.cod).isAvailable, isFalse);
    });
  });
}
