import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('PricingBreakdown Tests', () {
    test('Calculates pricing with discount according to specifications', () {
      final pricing = PricingBreakdown.calculate(
        packagePrice: 999.0,
        discount: 100.0,
        taxRate: 0.18,
      );

      // Package price = 999
      expect(pricing.packagePrice, 999.0);
      // Discount = 100
      expect(pricing.discount, 100.0);
      expect(pricing.hasDiscount, isTrue);
      // Taxable = 899 -> 18% of 899 = 161.82 -> rounds to 162
      expect(pricing.taxAmount, 162.0);
      // Total = 999 - 100 + 162 = 1061
      expect(pricing.totalAmount, 1061.0);
    });

    test('Calculates pricing without discount', () {
      final pricing = PricingBreakdown.calculate(
        packagePrice: 999.0,
        discount: 0.0,
        taxRate: 0.18,
      );

      expect(pricing.packagePrice, 999.0);
      expect(pricing.discount, 0.0);
      expect(pricing.hasDiscount, isFalse);
      // 18% of 999 = 179.82 -> rounds to 180
      expect(pricing.taxAmount, 180.0);
      // Total = 999 + 180 = 1179
      expect(pricing.totalAmount, 1179.0);
    });

    test('JSON serialization roundtrip and equality', () {
      final pricing = PricingBreakdown.calculate(
        packagePrice: 1499.0,
        discount: 200.0,
      );

      final json = pricing.toJson();
      expect(json['packagePrice'], 1499.0);
      expect(json['discount'], 200.0);

      final deserialized = PricingBreakdown.fromJson(json);
      expect(deserialized, equals(pricing));
      expect(deserialized.hashCode, equals(pricing.hashCode));
    });

    test('copyWith works correctly', () {
      const pricing = PricingBreakdown(
        packagePrice: 500.0,
        discount: 50.0,
        taxRate: 0.18,
        taxAmount: 81.0,
        totalAmount: 531.0,
      );

      final updated = pricing.copyWith(totalAmount: 550.0);
      expect(updated.totalAmount, 550.0);
      expect(updated.packagePrice, 500.0);
    });
  });

  group('BookingSummaryModel Tests', () {
    const service = ServiceModel(
      id: 'srv_1',
      categoryId: 'cat_1',
      name: 'Deep Home Cleaning',
      description: 'Comprehensive cleaning',
      startingPrice: 999.0,
    );

    const package = ServicePackageModel(
      id: 'pkg_1',
      serviceId: 'srv_1',
      name: 'Premium Package',
      description: 'Full house',
      price: 999.0,
      duration: '2 hrs',
      features: ['All rooms', 'Kitchen'],
    );

    const address = AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: 'Flat 302',
      addressLine: 'Royal Palms, Vaishali Nagar',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302021',
    );

    final scheduledDate = ServiceDateModel(
      date: DateTime(2026, 9, 26),
      isAvailable: true,
    );

    const timeSlot = TimeSlotModel(
      id: 'slot_1',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      isAvailable: true,
    );

    final pricing = PricingBreakdown.calculate(
      packagePrice: package.price,
      discount: 100.0,
    );

    test('Properties and isValid getter', () {
      final summary = BookingSummaryModel(
        service: service,
        package: package,
        address: address,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        pricing: pricing,
      );

      expect(summary.isValid, isTrue);
      expect(summary.service.name, 'Deep Home Cleaning');
      expect(summary.package.name, 'Premium Package');
      expect(summary.address.label, 'Home');
      expect(summary.pricing.totalAmount, 1061.0);
      expect(
        summary.formattedSchedule,
        contains('10:00 AM - 11:00 AM'),
      );
    });

    test('isValid is false if slot is unavailable or total is zero', () {
      final invalidSummary = BookingSummaryModel(
        service: service,
        package: package,
        address: address,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot.copyWith(isAvailable: false),
        pricing: pricing,
      );

      expect(invalidSummary.isValid, isFalse);
    });

    test('JSON serialization roundtrip', () {
      final summary = BookingSummaryModel(
        service: service,
        package: package,
        address: address,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        pricing: pricing,
      );

      final json = summary.toJson();
      expect(json['service']['id'], 'srv_1');
      expect(json['package']['id'], 'pkg_1');
      expect(json['address']['id'], 'addr_1');
      expect(json['pricing']['totalAmount'], 1061.0);

      final deserialized = BookingSummaryModel.fromJson(json);
      expect(deserialized.service.id, summary.service.id);
      expect(deserialized.package.id, summary.package.id);
      expect(deserialized.pricing.totalAmount, summary.pricing.totalAmount);
      expect(deserialized, equals(summary));
    });
  });
}
