import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_request_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('CreateBookingRequestModel Tests', () {
    const service = ServiceModel(
      id: 'srv_clean_1',
      categoryId: 'cat_cleaning',
      name: 'Full Home Deep Clean',
      description: 'Cleaning',
      startingPrice: 999.0,
    );

    const package = ServicePackageModel(
      id: 'pkg_3bhk',
      serviceId: 'srv_clean_1',
      name: 'Premium 3BHK',
      description: '3BHK complete',
      price: 999.0,
      duration: '2 hrs',
      features: ['Deep wash', 'Dusting'],
    );

    const address = AddressModel(
      id: 'addr_home',
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
      id: 'slot_morning',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      isAvailable: true,
    );

    final pricing = PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    );

    final summary = BookingSummaryModel(
      service: service,
      package: package,
      address: address,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      pricing: pricing,
    );

    const paymentMethod = PaymentMethodModel(
      id: 'pm_upi',
      title: 'UPI',
      subtitle: 'Google Pay, PhonePe, Paytm',
      type: PaymentMethodType.upi,
      isAvailable: true,
    );

    test('Creates request model from summary and payment accurately', () {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(request.serviceId, 'srv_clean_1');
      expect(request.packageId, 'pkg_3bhk');
      expect(request.addressId, 'addr_home');
      expect(request.scheduledDate, '2026-09-26');
      expect(request.timeSlotId, 'slot_morning');
      expect(request.paymentMethodId, 'pm_upi');
      expect(request.totalAmount, 1061.0);
    });

    test('Request model serialization to and from JSON produces identical values', () {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final json = request.toJson();
      final fromJson = CreateBookingRequestModel.fromJson(json);

      expect(fromJson.serviceId, request.serviceId);
      expect(fromJson.packageId, request.packageId);
      expect(fromJson.addressId, request.addressId);
      expect(fromJson.scheduledDate, request.scheduledDate);
      expect(fromJson.timeSlotId, request.timeSlotId);
      expect(fromJson.paymentMethodId, request.paymentMethodId);
      expect(fromJson.totalAmount, request.totalAmount);
    });

    test('Request model copyWith and equality work correctly', () {
      const request1 = CreateBookingRequestModel(
        serviceId: 's1',
        packageId: 'p1',
        addressId: 'a1',
        scheduledDate: '2026-09-26',
        timeSlotId: 't1',
        paymentMethodId: 'pm1',
        totalAmount: 999.0,
      );

      final request2 = request1.copyWith(paymentMethodId: 'pm2');
      expect(request2.paymentMethodId, 'pm2');
      expect(request1 == request2, isFalse);

      final request3 = request1.copyWith();
      expect(request1 == request3, isTrue);
      expect(request1.hashCode, request3.hashCode);
    });
  });
}
