import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('BookingRepositoryImpl Tests', () {
    late MockBookingRemoteDataSource dataSource;
    late BookingRepositoryImpl repository;

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
      features: ['Deep wash'],
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

    setUp(() {
      dataSource = MockBookingRemoteDataSource();
      repository = BookingRepositoryImpl(remoteDataSource: dataSource);
    });

    test('createBooking successfully returns created booking with exact selections', () async {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final booking = await repository.createBooking(
        request: request,
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(booking.bookingReference, startsWith('SC-2026-'));
      expect(booking.service.name, 'Full Home Deep Clean');
      expect(booking.package.name, 'Premium 3BHK');
      expect(booking.address.houseNumber, 'Flat 302');
      expect(booking.paymentMethod.title, 'UPI');
      expect(booking.pricing.totalAmount, 1061.0);
      expect(booking.isConfirmed, isTrue);
    });

    test('createBooking propagates exception when data source fails', () async {
      dataSource.shouldFail = true;

      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(
        () => repository.createBooking(
          request: request,
          summary: summary,
          paymentMethod: paymentMethod,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getBookings delegates to remoteDataSource and returns bookings', () async {
      final bookings = await repository.getBookings();

      expect(bookings, isNotEmpty);
      expect(bookings.length, 2);
      expect(bookings.first.bookingReference, 'SC-2026-000101');
    });

    test('getBookingById delegates to remoteDataSource and returns matching booking', () async {
      final booking = await repository.getBookingById('bk_seed_001');

      expect(booking.id, 'bk_seed_001');
      expect(booking.bookingReference, 'SC-2026-000101');
    });

    test('getBookingById propagates error when booking not found', () async {
      expect(
        () => repository.getBookingById('invalid_id'),
        throwsA(isA<Exception>()),
      );
    });

    test('cancelBooking delegates to remoteDataSource and returns updated booking', () async {
      const request = CancelBookingRequestModel(
        bookingId: 'bk_seed_001',
        reason: 'Changed my plans',
      );

      final cancelled = await repository.cancelBooking(request: request);

      expect(cancelled.id, 'bk_seed_001');
      expect(cancelled.status, BookingStatus.cancelled);
      expect(cancelled.cancellationReason, 'Changed my plans');
      expect(cancelled.isCancellable, isFalse);
    });

    test('cancelBooking with named bookingId and reason arguments delegates correctly', () async {
      final cancelled = await repository.cancelBooking(
        bookingId: 'bk_seed_001',
        reason: 'Booked by mistake',
      );

      expect(cancelled.id, 'bk_seed_001');
      expect(cancelled.status, BookingStatus.cancelled);
      expect(cancelled.cancellationReason, 'Booked by mistake');
    });

    test('cancelBooking propagates error when remoteDataSource fails', () async {
      dataSource.shouldFail = true;

      const request = CancelBookingRequestModel(
        bookingId: 'bk_seed_001',
        reason: 'Changed my plans',
      );

      expect(
        () => repository.cancelBooking(request: request),
        throwsA(isA<Exception>()),
      );
    });
  });
}
