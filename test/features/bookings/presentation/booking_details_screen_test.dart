import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_details_screen.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:provider/provider.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockBookingRemoteDataSource dataSource;
  late BookingRepositoryImpl repository;
  late BookingProvider provider;

  final sampleBooking = BookingModel(
    id: 'bk_test_001',
    bookingReference: 'SC-2026-000001',
    status: BookingStatus.confirmed,
    service: const ServiceModel(
      id: 'srv_1',
      categoryId: 'cat_1',
      name: 'Full Home Deep Clean',
      description: 'Cleaning',
      startingPrice: 999.0,
    ),
    package: const ServicePackageModel(
      id: 'pkg_1',
      serviceId: 'srv_1',
      name: 'Premium 3BHK',
      description: '3BHK',
      price: 999.0,
      duration: '2-3 hrs',
      features: ['Deep Scrubbing', 'Sanitization'],
    ),
    address: const AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: 'Flat 302',
      addressLine: 'Royal Palms, Vaishali Nagar',
      landmark: 'Near Central Mall',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302021',
    ),
    scheduledDate: ServiceDateModel(
      date: DateTime(2026, 9, 26),
      isAvailable: true,
    ),
    timeSlot: const TimeSlotModel(
      id: 'slot_1',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      isAvailable: true,
    ),
    paymentMethod: const PaymentMethodModel(
      id: 'pm_upi',
      title: 'UPI',
      subtitle: 'Google Pay, PhonePe, Paytm',
      type: PaymentMethodType.upi,
      isAvailable: true,
    ),
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
    createdAt: DateTime(2026, 9, 23, 10, 0),
  );

  setUp(() {
    dataSource = MockBookingRemoteDataSource();
    repository = BookingRepositoryImpl(remoteDataSource: dataSource);
    provider = BookingProvider(repository: repository);
  });

  Widget buildTestApp(Widget screen) {
    return ChangeNotifierProvider<BookingProvider>.value(
      value: provider,
      child: MaterialApp(
        home: screen,
      ),
    );
  }

  group('BookingDetailsScreen Widget Tests', () {
    testWidgets('Renders all booking sections and accurate details', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: sampleBooking.id,
            initialBooking: sampleBooking,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // 1. App Bar Title
      expect(find.text('Booking Details'), findsOneWidget);

      // 2. Status Banner
      expect(find.text('Confirmed'), findsWidgets);
      expect(find.textContaining('Your service has been confirmed'), findsOneWidget);

      // 3. Booking Reference Card
      expect(find.text('SC-2026-000001'), findsOneWidget);
      expect(find.byTooltip('Copy Reference ID'), findsOneWidget);

      // 4. Service & Package
      expect(find.text('Full Home Deep Clean'), findsOneWidget);
      expect(find.text('Premium 3BHK • 2-3 hrs'), findsOneWidget);
      expect(find.text('Deep Scrubbing'), findsOneWidget);
      expect(find.text('Sanitization'), findsOneWidget);

      // 5. Schedule
      expect(find.textContaining('26 Sep 2026'), findsOneWidget);
      expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);

      // 6. Address
      expect(find.text('Flat 302, Royal Palms, Vaishali Nagar'), findsOneWidget);
      expect(find.text('Landmark: Near Central Mall'), findsOneWidget);
      expect(find.text('Jaipur, Rajasthan - 302021'), findsOneWidget);

      // 7. Payment
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Prepaid Online'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);

      // 8. Price Breakdown
      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.text('Package Price'), findsOneWidget);
      expect(find.text('₹999'), findsOneWidget);
      expect(find.text('-₹100'), findsOneWidget);
      expect(find.text('₹1,061'), findsOneWidget);
    });

    testWidgets('Tapping copy button copies reference and shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: sampleBooking.id,
            initialBooking: sampleBooking,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.byTooltip('Copy Reference ID');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Booking ID copied to clipboard'), findsOneWidget);
    });

    testWidgets('Renders not found state when booking does not exist', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const BookingDetailsScreen(
            bookingId: 'invalid_booking_id',
            initialBooking: null,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('Booking not found'), findsOneWidget);
      expect(find.text('This booking may no longer be available.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Back to My Bookings'), findsOneWidget);
    });

    testWidgets('Responsive layout checks at 360, 390, 412px with zero overflows',
        (tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          buildTestApp(
            BookingDetailsScreen(
              bookingId: sampleBooking.id,
              initialBooking: sampleBooking,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        expect(find.text('Booking Details'), findsOneWidget);
        expect(find.text('SC-2026-000001'), findsOneWidget);
        expect(find.text('₹1,061'), findsOneWidget);

        expect(tester.takeException(), isNull);
      }

      tester.view.resetPhysicalSize();
    });

    testWidgets('Shows Cancel Booking button for confirmed booking', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      provider.setSelectedBooking(sampleBooking);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: sampleBooking.id,
            initialBooking: sampleBooking,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsOneWidget);
    });

    testWidgets('Hides Cancel Booking button for completed booking', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final completedBooking = sampleBooking.copyWith(
        id: 'bk_seed_002', // matches completed seed in MockBookingRemoteDataSource
        status: BookingStatus.completed,
      );
      provider.setSelectedBooking(completedBooking);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: completedBooking.id,
            initialBooking: completedBooking,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsNothing);
    });

    testWidgets('Hides Cancel Booking button and shows reason for cancelled booking',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cancelledBooking = sampleBooking.copyWith(
        id: 'bk_cancelled_01',
        status: BookingStatus.cancelled,
        cancellationReason: 'Changed my plans',
        cancellationNote: 'Rescheduled elsewhere',
      );
      provider.setSelectedBooking(cancelledBooking);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: cancelledBooking.id,
            initialBooking: cancelledBooking,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsNothing);
      expect(
        find.textContaining('This booking was cancelled. Reason: Changed my plans.'),
        findsOneWidget,
      );
      expect(find.text('Note: "Rescheduled elsewhere"'), findsOneWidget);
    });

    testWidgets('Tapping Cancel Booking opens CancellationReasonSheet modal bottom sheet',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingDetailsScreen(
            bookingId: sampleBooking.id,
            initialBooking: sampleBooking,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cancelBtn = find.text('Cancel Booking');
      expect(cancelBtn, findsOneWidget);

      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify the sheet opened
      expect(find.text('Are you sure you want to cancel this booking? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Please select a reason for cancellation:'), findsOneWidget);
      expect(find.text('Keep Booking'), findsOneWidget);
    });
  });
}
