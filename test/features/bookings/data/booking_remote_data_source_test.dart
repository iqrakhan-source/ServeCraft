import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_request_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('MockBookingRemoteDataSource Tests', () {
    late MockBookingRemoteDataSource dataSource;

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
    });

    test('Initializes with 2 deterministic seeded bookings', () async {
      final bookings = await dataSource.getBookings();

      expect(bookings.length, 2);
      expect(bookings[0].bookingReference, 'SC-2026-000101');
      expect(bookings[0].status, BookingStatus.confirmed);
      expect(bookings[1].bookingReference, 'SC-2026-000099');
      expect(bookings[1].status, BookingStatus.completed);
    });

    test('createBooking adds newly created booking to in-memory session list', () async {
      final request = CreateBookingRequestModel.fromSummaryAndPayment(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final created = await dataSource.createBooking(
        request: request,
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final bookings = await dataSource.getBookings();

      expect(bookings.length, 3);
      expect(bookings.first.id, created.id);
      expect(bookings.first.bookingReference, created.bookingReference);
      expect(bookings.first.service.name, 'Full Home Deep Clean');
      expect(bookings.first.pricing.totalAmount, 1061.0);
    });

    test('getBookingById finds booking by ID and by reference', () async {
      final byId = await dataSource.getBookingById('bk_seed_001');
      expect(byId.bookingReference, 'SC-2026-000101');

      final byRef = await dataSource.getBookingById('SC-2026-000099');
      expect(byRef.id, 'bk_seed_002');
      expect(byRef.status, BookingStatus.completed);
    });

    test('getBookingById throws NotFoundException when ID does not exist', () async {
      expect(
        () => dataSource.getBookingById('non_existent_id'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Throws UnexpectedException when shouldFail is true', () async {
      dataSource.shouldFail = true;

      expect(
        () => dataSource.getBookings(),
        throwsA(isA<UnexpectedException>()),
      );

      expect(
        () => dataSource.getBookingById('bk_seed_001'),
        throwsA(isA<UnexpectedException>()),
      );
    });

    group('cancelBooking Tests', () {
      test('Cancels confirmed booking, updates status and preserves metadata', () async {
        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
          reasonNote: 'Need to travel urgently',
        );

        final result = await dataSource.cancelBooking(request: request);

        expect(result.id, 'bk_seed_001');
        expect(result.status, BookingStatus.cancelled);
        expect(result.cancellationReason, 'Changed my plans');
        expect(result.cancellationNote, 'Need to travel urgently');
        expect(result.cancelledAt, isNotNull);
        expect(result.service.name, 'Home Deep Cleaning');
        expect(result.pricing.totalAmount, 1061.0);

        // Verify update in in-memory session list
        final refreshed = await dataSource.getBookingById('bk_seed_001');
        expect(refreshed.status, BookingStatus.cancelled);
        expect(refreshed.cancellationReason, 'Changed my plans');
      });

      test('Throws BadRequestException if booking is already completed or not cancellable', () async {
        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_002', // completed seed
          reason: 'Other',
        );

        expect(
          () => dataSource.cancelBooking(request: request),
          throwsA(isA<BadRequestException>()),
        );
      });

      test('Throws NotFoundException when cancelling non-existent booking', () async {
        const request = CancelBookingRequestModel(
          bookingId: 'unknown_booking_id',
          reason: 'Changed my plans',
        );

        expect(
          () => dataSource.cancelBooking(request: request),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('Throws UnexpectedException when shouldFail is true during cancellation', () async {
        dataSource.shouldFail = true;
        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
        );

        expect(
          () => dataSource.cancelBooking(request: request),
          throwsA(isA<UnexpectedException>()),
        );
      });

      test('Cancels pending booking successfully and accepts cancellation reason', () async {
        final original = await dataSource.getBookingById('bk_seed_001');
        final pendingBooking = original.copyWith(
          id: 'bk_pending_test',
          status: BookingStatus.pending,
        );
        dataSource.addBooking(pendingBooking);

        final result = await dataSource.cancelBooking(
          bookingId: 'bk_pending_test',
          reason: 'Schedule no longer works',
        );

        expect(result.id, 'bk_pending_test');
        expect(result.status, BookingStatus.cancelled);
        expect(result.cancellationReason, 'Schedule no longer works');
      });

      test('Throws BadRequestException when attempting to cancel an already cancelled booking', () async {
        final original = await dataSource.getBookingById('bk_seed_001');
        final cancelledBooking = original.copyWith(
          id: 'bk_already_cancelled',
          status: BookingStatus.cancelled,
        );
        dataSource.addBooking(cancelledBooking);

        expect(
          () => dataSource.cancelBooking(
            bookingId: 'bk_already_cancelled',
            reason: 'Booked by mistake',
          ),
          throwsA(isA<BadRequestException>()),
        );
      });

      test('Cancelling booking preserves all other fields unchanged', () async {
        final original = await dataSource.getBookingById('bk_seed_001');

        final result = await dataSource.cancelBooking(
          request: const CancelBookingRequestModel(
            bookingId: 'bk_seed_001',
            reason: 'Found another service',
          ),
        );

        expect(result.id, equals(original.id));
        expect(result.bookingReference, equals(original.bookingReference));
        expect(result.service, equals(original.service));
        expect(result.package, equals(original.package));
        expect(result.address, equals(original.address));
        expect(result.scheduledDate, equals(original.scheduledDate));
        expect(result.timeSlot, equals(original.timeSlot));
        expect(result.paymentMethod, equals(original.paymentMethod));
        expect(result.pricing, equals(original.pricing));
        expect(result.createdAt, equals(original.createdAt));
        expect(result.status, equals(BookingStatus.cancelled));
        expect(result.cancellationReason, equals('Found another service'));
        expect(result.cancelledAt, isNotNull);
      });
    });
  });
}
