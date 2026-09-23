import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('BookingModel & BookingStatus Tests', () {
    const service = ServiceModel(
      id: 'srv_1',
      categoryId: 'cat_1',
      name: 'Full Home Deep Clean',
      description: 'Cleaning',
      startingPrice: 999.0,
    );

    const package = ServicePackageModel(
      id: 'pkg_1',
      serviceId: 'srv_1',
      name: 'Premium 3BHK',
      description: '3BHK complete',
      price: 999.0,
      duration: '2 hrs',
      features: ['Deep wash', 'Dusting'],
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

    const paymentMethod = PaymentMethodModel(
      id: 'pm_upi',
      title: 'UPI',
      subtitle: 'Google Pay, PhonePe, Paytm',
      type: PaymentMethodType.upi,
      isAvailable: true,
    );

    final pricing = PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    );

    final testCreatedAt = DateTime(2026, 9, 23, 12, 0);

    final booking = BookingModel(
      id: 'bk_1',
      bookingReference: 'SC-2026-000001',
      status: BookingStatus.confirmed,
      service: service,
      package: package,
      address: address,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      paymentMethod: paymentMethod,
      pricing: pricing,
      createdAt: testCreatedAt,
    );

    test('BookingStatus enum helper methods work correctly', () {
      expect(BookingStatus.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatus.fromString('pending'), BookingStatus.pending);
      expect(BookingStatus.fromString('cancelled'), BookingStatus.cancelled);
      expect(BookingStatus.fromString('completed'), BookingStatus.completed);
      expect(BookingStatus.fromString('unknown'), BookingStatus.confirmed);

      expect(BookingStatus.confirmed.toFormattedString(), 'confirmed');
      expect(BookingStatus.confirmed.displayName, 'Confirmed');
    });

    test('BookingModel getters return expected formatted values', () {
      expect(booking.formattedBookingReference, 'SC-2026-000001');
      expect(booking.formattedTotal, '₹1,061');
      expect(booking.isConfirmed, isTrue);
      expect(booking.formattedSchedule, contains('10:00 AM - 11:00 AM'));
    });

    test('BookingModel serialization to and from JSON produces identical values', () {
      final json = booking.toJson();
      final fromJson = BookingModel.fromJson(json);

      expect(fromJson.id, booking.id);
      expect(fromJson.bookingReference, booking.bookingReference);
      expect(fromJson.status, booking.status);
      expect(fromJson.service.name, booking.service.name);
      expect(fromJson.package.name, booking.package.name);
      expect(fromJson.address.houseNumber, booking.address.houseNumber);
      expect(fromJson.paymentMethod.title, booking.paymentMethod.title);
      expect(fromJson.pricing.totalAmount, booking.pricing.totalAmount);
    });

    test('BookingModel equality and copyWith work as expected', () {
      final copy = booking.copyWith(bookingReference: 'SC-2026-000002');
      expect(copy.bookingReference, 'SC-2026-000002');
      expect(copy.id, booking.id);
      expect(copy == booking, isFalse);

      final identicalCopy = booking.copyWith();
      expect(identicalCopy == booking, isTrue);
      expect(identicalCopy.hashCode, booking.hashCode);
    });
  });
}
