import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

void main() {
  group('PaymentMethodModel Tests', () {
    const upiMethod = PaymentMethodModel(
      id: 'pm_upi',
      title: 'UPI',
      subtitle: 'Pay using any UPI app',
      type: PaymentMethodType.upi,
      isAvailable: true,
      iconName: 'upi_icon',
    );

    test('Properties and creation', () {
      expect(upiMethod.id, 'pm_upi');
      expect(upiMethod.title, 'UPI');
      expect(upiMethod.subtitle, 'Pay using any UPI app');
      expect(upiMethod.type, PaymentMethodType.upi);
      expect(upiMethod.isAvailable, isTrue);
      expect(upiMethod.iconName, 'upi_icon');
    });

    test('PaymentMethodType enum fromString and toFormattedString', () {
      expect(PaymentMethodType.fromString('upi'), PaymentMethodType.upi);
      expect(PaymentMethodType.fromString('card'), PaymentMethodType.card);
      expect(PaymentMethodType.fromString('cod'), PaymentMethodType.cod);
      expect(PaymentMethodType.fromString('cash_on_delivery'), PaymentMethodType.cod);
      expect(PaymentMethodType.fromString('unknown'), PaymentMethodType.upi);

      expect(PaymentMethodType.upi.toFormattedString(), 'upi');
      expect(PaymentMethodType.card.toFormattedString(), 'card');
      expect(PaymentMethodType.cod.toFormattedString(), 'cod');
    });

    test('copyWith works correctly', () {
      final updated = upiMethod.copyWith(
        isAvailable: false,
        title: 'UPI (Unavailable)',
      );

      expect(updated.id, 'pm_upi');
      expect(updated.isAvailable, isFalse);
      expect(updated.title, 'UPI (Unavailable)');
      expect(updated.type, PaymentMethodType.upi);
    });

    test('JSON serialization roundtrip and equality', () {
      final json = upiMethod.toJson();
      expect(json['id'], 'pm_upi');
      expect(json['title'], 'UPI');
      expect(json['type'], 'upi');
      expect(json['isAvailable'], isTrue);

      final deserialized = PaymentMethodModel.fromJson(json);
      expect(deserialized, equals(upiMethod));
      expect(deserialized.hashCode, equals(upiMethod.hashCode));
    });
  });
}
