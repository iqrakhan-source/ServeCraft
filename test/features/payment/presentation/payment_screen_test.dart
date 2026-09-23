import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:prop_crm/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:prop_crm/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:prop_crm/features/payment/presentation/providers/payment_provider.dart';
import 'package:prop_crm/features/payment/presentation/screens/payment_screen.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:provider/provider.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockPaymentRemoteDataSource dataSource;
  late PaymentRepositoryImpl repository;
  late PaymentProvider provider;
  late MockBookingRemoteDataSource bookingDataSource;
  late BookingRepositoryImpl bookingRepository;
  late BookingProvider bookingProvider;

  final sampleSummary = BookingSummaryModel(
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
      duration: '2 hrs',
      features: ['Deep wash'],
    ),
    address: const AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: 'Flat 302',
      addressLine: 'Royal Palms',
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
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
  );

  setUp(() {
    dataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(remoteDataSource: dataSource);
    provider = PaymentProvider(repository: repository);
    bookingDataSource = MockBookingRemoteDataSource();
    bookingRepository = BookingRepositoryImpl(remoteDataSource: bookingDataSource);
    bookingProvider = BookingProvider(repository: bookingRepository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PaymentProvider>.value(value: provider),
        ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('PaymentScreen Widget & Flow Tests', () {
    testWidgets('Case 1: Open Payment with no method selected - amount visible, methods visible, Continue disabled',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          PaymentScreen(bookingSummary: sampleSummary),
        ),
      );

      // Advance async loading & frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // 1. Verify app bar title
      expect(find.text('Payment'), findsOneWidget);

      // 2. Verify amount card displays ₹1,061 and service name
      expect(find.text('Amount to Pay'), findsOneWidget);
      expect(find.text('₹1,061'), findsWidgets);
      expect(find.text('Full Home Deep Clean • Premium 3BHK'), findsOneWidget);

      // 3. Verify section heading
      expect(find.text('Select Payment Method'), findsOneWidget);

      // 4. Verify payment method options are visible
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);

      // 5. Verify security note
      expect(find.text('Secure Preference Selection'), findsOneWidget);

      // 6. Verify Continue CTA is disabled because no method is selected yet
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(continueButton);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('Case 2 & 3: Selecting UPI enables Continue CTA and switching to Card updates selection',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          PaymentScreen(bookingSummary: sampleSummary),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Select UPI
      await tester.tap(find.text('UPI'));
      await tester.pumpAndSettle();

      // Verify provider selection updated
      expect(provider.selectedMethod?.type.name, 'upi');
      expect(provider.isSelectionValid, isTrue);

      // Verify Continue button is now enabled
      var continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      var elevatedButton = tester.widget<ElevatedButton>(continueButton);
      expect(elevatedButton.onPressed, isNotNull);

      // Switch to Card
      await tester.tap(find.text('Credit / Debit Card'));
      await tester.pumpAndSettle();

      // Verify provider selection changed to Card
      expect(provider.selectedMethod?.type.name, 'card');
      expect(provider.isSelectionValid, isTrue);
    });

    testWidgets('Case 4: Selecting method, tapping Continue opens review, and Confirm Booking completes booking',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          PaymentScreen(bookingSummary: sampleSummary),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Select UPI
      await tester.tap(find.text('UPI'));
      await tester.pumpAndSettle();

      // Tap Continue to open review modal
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Review modal is shown
      expect(find.text('Review & Confirm Booking'), findsOneWidget);
      expect(find.text('Payable Amount'), findsOneWidget);

      // Tap Confirm Booking
      final confirmButton =
          find.widgetWithText(ElevatedButton, 'Confirm Booking');
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);

      // Advance through network delay and settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Lands on Booking Confirmation Screen
      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.textContaining('SC-2026-'), findsOneWidget);
    });

    testWidgets('Renders incomplete state when booking summary / amount is missing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const PaymentScreen(bookingSummary: null),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.text('No Payable Amount'), findsOneWidget);
      expect(find.text('Return to Summary'), findsOneWidget);
    });

    testWidgets('Case 5: Responsive layout tests at 360px, 390px, and 412px with zero overflows',
        (tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          buildTestApp(
            PaymentScreen(bookingSummary: sampleSummary),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        // Verify key widgets rendered properly without overflow
        expect(find.text('Amount to Pay'), findsOneWidget);
        expect(find.text('Select Payment Method'), findsOneWidget);
        expect(find.text('UPI'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);

        // Ensure no exception or overflow occurred
        expect(tester.takeException(), isNull);
      }

      tester.view.resetPhysicalSize();
    });
  });
}
