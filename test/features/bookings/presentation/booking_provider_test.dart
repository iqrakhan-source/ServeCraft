import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  group('BookingProvider Tests', () {
    late MockBookingRemoteDataSource dataSource;
    late BookingRepositoryImpl repository;
    late BookingProvider provider;

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
      provider = BookingProvider(repository: repository);
    });

    test('Initial state is clean', () {
      expect(provider.bookingState.isInitial, isTrue);
      expect(provider.isCreating, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.createdBooking, isNull);
    });

    test('Validation fails when summary is null or invalid', () async {
      final result = await provider.createBooking(
        summary: summary.copyWith(
          pricing: const PricingBreakdown(
            packagePrice: 0,
            discount: 0,
            taxRate: 0,
            taxAmount: 0,
            totalAmount: 0,
          ),
        ),
        paymentMethod: paymentMethod,
      );

      expect(result, isNull);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Some required booking information is missing'));
    });

    test('Validation fails when payment method is unavailable', () async {
      final unavailableMethod = paymentMethod.copyWith(isAvailable: false);
      final result = await provider.createBooking(
        summary: summary,
        paymentMethod: unavailableMethod,
      );

      expect(result, isNull);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('valid payment method'));
    });

    test('createBooking successfully creates booking and updates state', () async {
      final future = provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(provider.isCreating, isTrue);

      final result = await future;

      expect(result, isNotNull);
      expect(provider.isSuccess, isTrue);
      expect(provider.isCreating, isFalse);
      expect(provider.createdBooking, result);
      expect(result!.bookingReference, startsWith('SC-2026-'));
      expect(result.pricing.totalAmount, 1061.0);
    });

    test('createBooking handles repository error cleanly', () async {
      dataSource.shouldFail = true;

      final result = await provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(result, isNull);
      expect(provider.hasError, isTrue);
      expect(provider.isCreating, isFalse);
      expect(provider.createdBooking, isNull);
      expect(provider.errorMessage, isNotEmpty);
    });

    test('Prevents duplicate submission while creation is running', () async {
      // Start first creation
      final future1 = provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      // Immediately attempt second creation while first is in progress
      final future2 = provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      final result2 = await future2;
      expect(result2, isNull, reason: 'Second request must be blocked while creating');

      final result1 = await future1;
      expect(result1, isNotNull);
    });

    test('reset clears state and booking', () async {
      await provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );
      expect(provider.isSuccess, isTrue);

      provider.reset();
      expect(provider.bookingState.isInitial, isTrue);
      expect(provider.createdBooking, isNull);
    });

    test('Initial list & details states are clean', () {
      expect(provider.bookingsState.isInitial, isTrue);
      expect(provider.detailsState.isInitial, isTrue);
      expect(provider.bookings, isEmpty);
      expect(provider.selectedBooking, isNull);
      expect(provider.activeFilter, BookingFilter.all);
      expect(provider.isLoadingBookings, isFalse);
      expect(provider.isLoadingDetails, isFalse);
    });

    test('loadBookings loads seeded bookings successfully', () async {
      await provider.loadBookings();

      expect(provider.bookingsState.isSuccess, isTrue);
      expect(provider.bookings.length, 2);
      expect(provider.filteredBookings.length, 2);
    });

    test('loadBookings handles repository failure cleanly', () async {
      dataSource.shouldFail = true;

      await provider.loadBookings();

      expect(provider.bookingsState.isError, isTrue);
      expect(provider.bookingsErrorMessage, contains('load your bookings'));
    });

    test('Filter logic partitions bookings deterministically', () async {
      await provider.loadBookings();

      // All filter
      provider.setFilter(BookingFilter.all);
      expect(provider.filteredBookings.length, 2);

      // Upcoming filter (contains Confirmed & Pending)
      provider.setFilter(BookingFilter.upcoming);
      expect(provider.filteredBookings.length, 1);
      expect(provider.filteredBookings.first.status, BookingStatus.confirmed);

      // Completed filter
      provider.setFilter(BookingFilter.completed);
      expect(provider.filteredBookings.length, 1);
      expect(provider.filteredBookings.first.status, BookingStatus.completed);

      // Cancelled filter (empty)
      provider.setFilter(BookingFilter.cancelled);
      expect(provider.filteredBookings, isEmpty);
    });

    test('loadBookingDetails loads specific booking into selectedBooking', () async {
      final booking = await provider.loadBookingDetails('bk_seed_001');

      expect(booking, isNotNull);
      expect(provider.selectedBooking?.id, 'bk_seed_001');
      expect(provider.detailsState.isSuccess, isTrue);
    });

    test('loadBookingDetails sets error state on invalid ID', () async {
      final booking = await provider.loadBookingDetails('non_existent_id');

      expect(booking, isNull);
      expect(provider.detailsState.isError, isTrue);
      expect(provider.detailsErrorMessage, isNotEmpty);
    });

    test('createBooking automatically prepends new booking to loaded bookings list', () async {
      // First load bookings
      await provider.loadBookings();
      expect(provider.bookings.length, 2);

      // Create new booking
      final created = await provider.createBooking(
        summary: summary,
        paymentMethod: paymentMethod,
      );

      expect(created, isNotNull);
      expect(provider.bookings.length, 3);
      expect(provider.bookings.first.id, created!.id);
      expect(provider.bookings.first.bookingReference, created.bookingReference);
    });

    group('cancelBooking Tests', () {
      test('cancelBooking updates cancellation state, selectedBooking, and bookings list', () async {
        await provider.loadBookings();
        await provider.loadBookingDetails('bk_seed_001');

        expect(provider.selectedBooking?.status, BookingStatus.confirmed);
        expect(provider.cancellationState.isInitial, isTrue);

        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
          reasonNote: 'Leaving town',
        );

        final cancelled = await provider.cancelBooking(request: request);

        expect(cancelled, isNotNull);
        expect(cancelled?.status, BookingStatus.cancelled);
        expect(cancelled?.cancellationReason, 'Changed my plans');
        expect(cancelled?.cancellationNote, 'Leaving town');

        // Verify provider state updates
        expect(provider.cancellationState.isSuccess, isTrue);
        expect(provider.selectedBooking?.status, BookingStatus.cancelled);
        expect(provider.detailsState.data?.status, BookingStatus.cancelled);

        // Verify list reflection
        final matchInList = provider.bookings.firstWhere((b) => b.id == 'bk_seed_001');
        expect(matchInList.status, BookingStatus.cancelled);

        // Verify filtered reflection
        provider.setFilter(BookingFilter.upcoming);
        expect(provider.filteredBookings.any((b) => b.id == 'bk_seed_001'), isFalse);

        provider.setFilter(BookingFilter.cancelled);
        expect(provider.filteredBookings.any((b) => b.id == 'bk_seed_001'), isTrue);
      });

      test('cancelBooking handles repository failure cleanly', () async {
        dataSource.shouldFail = true;

        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
        );

        final result = await provider.cancelBooking(request: request);

        expect(result, isNull);
        expect(provider.cancellationState.isError, isTrue);
        expect(provider.cancellationError, isNotEmpty);
      });

      test('resetCancellationState restores cancellationState to initial', () async {
        dataSource.shouldFail = true;

        const request = CancelBookingRequestModel(
          bookingId: 'bk_seed_001',
          reason: 'Other',
        );

        await provider.cancelBooking(request: request);
        expect(provider.cancellationState.isError, isTrue);

        provider.resetCancellationState();
        expect(provider.cancellationState.isInitial, isTrue);
        expect(provider.cancellationError, isNull);
      });

      test('cancellation loading state transitions properly', () async {
        await provider.loadBookings();
        await provider.loadBookingDetails('bk_seed_001');

        expect(provider.isCancelling, isFalse);

        final cancelFuture = provider.cancelBooking(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
        );

        expect(provider.isCancelling, isTrue);
        expect(provider.cancellationState.isLoading, isTrue);

        final result = await cancelFuture;
        expect(result, isNotNull);
        expect(provider.isCancelling, isFalse);
        expect(provider.cancellationState.isSuccess, isTrue);
      });

      test('duplicate submission prevention ignores concurrent calls', () async {
        await provider.loadBookings();

        // Fire first cancellation
        final firstFuture = provider.cancelBooking(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
        );

        // Immediate second cancellation while first is in-flight
        final secondResult = await provider.cancelBooking(
          bookingId: 'bk_seed_001',
          reason: 'Booked by mistake',
        );

        // Second should be rejected immediately due to isCancelling guard
        expect(secondResult, isNull);

        final firstResult = await firstFuture;
        expect(firstResult, isNotNull);
        expect(firstResult?.cancellationReason, 'Changed my plans');
      });

      test('failed cancellation does not change booking status in selectedBooking or list', () async {
        await provider.loadBookings();
        await provider.loadBookingDetails('bk_seed_001');

        expect(provider.selectedBooking?.status, BookingStatus.confirmed);
        dataSource.shouldFail = true;

        final result = await provider.cancelBooking(
          bookingId: 'bk_seed_001',
          reason: 'Changed my plans',
        );

        expect(result, isNull);
        expect(provider.selectedBooking?.status, BookingStatus.confirmed);
        expect(provider.detailsState.data?.status, BookingStatus.confirmed);

        final matchInList = provider.bookings.firstWhere((b) => b.id == 'bk_seed_001');
        expect(matchInList.status, BookingStatus.confirmed);
      });
    });
  });
}
