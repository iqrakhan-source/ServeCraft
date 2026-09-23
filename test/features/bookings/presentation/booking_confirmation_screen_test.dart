import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:prop_crm/features/bookings/presentation/screens/my_bookings_screen.dart';
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
    id: 'bk_1',
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
      description: '3BHK complete',
      price: 999.0,
      duration: '2 hrs',
      features: ['Deep wash', 'Dusting'],
    ),
    address: const AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: 'Flat 302',
      addressLine: 'Royal Palms, Vaishali Nagar',
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
      endTime: '11:00 AM',
      isAvailable: true,
    ),
    paymentMethod: const PaymentMethodModel(
      id: 'pm_upi',
      title: 'UPI',
      subtitle: 'Google Pay, PhonePe',
      type: PaymentMethodType.upi,
      isAvailable: true,
    ),
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
    createdAt: DateTime(2026, 9, 23),
  );

  setUp(() {
    dataSource = MockBookingRemoteDataSource();
    repository = BookingRepositoryImpl(remoteDataSource: dataSource);
    provider = BookingProvider(repository: repository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookingProvider>.value(value: provider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('BookingConfirmationScreen Widget Tests', () {
    testWidgets('Renders all confirmation sections and data accurately',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingConfirmationScreen(booking: sampleBooking),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Success header
      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Your service has been successfully scheduled.'), findsOneWidget);

      // 2. Reference card
      expect(find.text('Booking ID'), findsOneWidget);
      expect(find.text('SC-2026-000001'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      // 3. Service details
      expect(find.text('Full Home Deep Clean'), findsOneWidget);
      expect(find.text('Premium 3BHK'), findsOneWidget);

      // 4. Schedule details
      expect(find.text('Scheduled Date & Time'), findsOneWidget);
      expect(find.textContaining('10:00 AM - 11:00 AM'), findsOneWidget);

      // 5. Address details
      expect(find.text('Service Address'), findsOneWidget);
      expect(find.text('Flat 302, Royal Palms, Vaishali Nagar'), findsOneWidget);
      expect(find.text('Jaipur, Rajasthan - 302021'), findsOneWidget);

      // 6. Payment method and total
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('₹1,061'), findsOneWidget);

      // 7. What's Next card
      expect(find.text("What's Next?"), findsOneWidget);
      expect(find.text('Partner Assignment'), findsOneWidget);
      expect(find.text('On-time Arrival'), findsOneWidget);
      expect(find.text('Manage Booking'), findsOneWidget);

      // 8. CTAs
      expect(find.widgetWithText(ElevatedButton, 'Back to Home'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'View My Bookings'), findsOneWidget);
    });

    testWidgets('Tapping copy booking reference button shows confirmation snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingConfirmationScreen(booking: sampleBooking),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.byTooltip('Copy Booking ID');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Booking ID copied to clipboard'), findsOneWidget);
    });

    testWidgets('Tapping View My Bookings navigates to My Bookings screen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          BookingConfirmationScreen(booking: sampleBooking),
        ),
      );

      await tester.pumpAndSettle();

      final viewBookingsButton = find.widgetWithText(ElevatedButton, 'View My Bookings');
      expect(viewBookingsButton, findsOneWidget);

      await tester.tap(viewBookingsButton);
      await tester.pumpAndSettle();

      // Navigates to real My Bookings screen
      expect(find.byType(MyBookingsScreen), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('Renders empty state when no booking is available', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const BookingConfirmationScreen(booking: null),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Booking Found'), findsOneWidget);
      expect(find.text('Return to Home'), findsOneWidget);
    });

    testWidgets('Responsive layouts render cleanly without overflow at 360, 390, 412px',
        (tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 900.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          buildTestApp(
            BookingConfirmationScreen(booking: sampleBooking),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Booking Confirmed'), findsOneWidget);
        expect(find.text('SC-2026-000001'), findsOneWidget);
        expect(find.text('Back to Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      tester.view.resetPhysicalSize();
    });
  });
}
