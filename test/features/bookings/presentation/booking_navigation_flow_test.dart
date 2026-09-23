import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_details_screen.dart';
import 'package:prop_crm/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
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

  late MockPaymentRemoteDataSource paymentDataSource;
  late PaymentRepositoryImpl paymentRepository;
  late PaymentProvider paymentProvider;

  late MockBookingRemoteDataSource bookingDataSource;
  late BookingRepositoryImpl bookingRepository;
  late BookingProvider bookingProvider;

  final sampleSummary = BookingSummaryModel(
    service: const ServiceModel(
      id: 'srv_deep_clean',
      categoryId: 'cat_cleaning',
      name: 'Full Home Deep Clean',
      description: 'Comprehensive sanitization and scrubbing.',
      startingPrice: 999.0,
    ),
    package: const ServicePackageModel(
      id: 'pkg_premium_3bhk',
      serviceId: 'srv_deep_clean',
      name: 'Premium 3BHK',
      description: '3BHK complete home cleaning',
      price: 999.0,
      duration: '2-3 hrs',
      features: ['Deep wash', 'Sanitization'],
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
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
  );

  setUp(() {
    paymentDataSource = MockPaymentRemoteDataSource();
    paymentRepository = PaymentRepositoryImpl(remoteDataSource: paymentDataSource);
    paymentProvider = PaymentProvider(repository: paymentRepository);

    bookingDataSource = MockBookingRemoteDataSource();
    bookingRepository = BookingRepositoryImpl(remoteDataSource: bookingDataSource);
    bookingProvider = BookingProvider(repository: bookingRepository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PaymentProvider>.value(value: paymentProvider),
        ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  testWidgets(
      'Full Phase 4 Flow: Checkout -> Confirmation -> My Bookings -> Booking Details preserves exact data session consistency',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Launch PaymentScreen
    await tester.pumpWidget(
      buildTestApp(
        PaymentScreen(bookingSummary: sampleSummary),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // 2. Select UPI
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();

    // 3. Tap Continue
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // 4. Confirm Booking in review modal
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Booking'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 5. Lands on BookingConfirmationScreen
    expect(find.byType(BookingConfirmationScreen), findsOneWidget);
    expect(find.text('Booking Confirmed'), findsOneWidget);

    final createdBooking = bookingProvider.createdBooking;
    expect(createdBooking, isNotNull);
    final bookingRef = createdBooking!.bookingReference;
    expect(find.text(bookingRef), findsOneWidget);

    // 6. Tap View My Bookings
    final viewBookingsButton = find.widgetWithText(ElevatedButton, 'View My Bookings');
    expect(viewBookingsButton, findsOneWidget);
    await tester.tap(viewBookingsButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // 7. Lands on MyBookingsScreen
    expect(find.byType(MyBookingsScreen), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);

    // 8. The newly created booking is displayed at the top of the list!
    expect(find.text('Full Home Deep Clean'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsWidgets);
    expect(find.text('₹1,061'), findsWidgets);

    // 9. Tap on the newly created booking card
    await tester.tap(find.text('Full Home Deep Clean'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 10. Lands on BookingDetailsScreen
    expect(find.byType(BookingDetailsScreen), findsOneWidget);
    expect(find.text('Booking Details'), findsOneWidget);

    // 11. Verify exact booking details match the session-created booking
    expect(find.text(bookingRef), findsOneWidget);
    expect(find.text('Full Home Deep Clean'), findsOneWidget);
    expect(find.text('Premium 3BHK • 2-3 hrs'), findsOneWidget);
    expect(find.textContaining('26 Sep 2026'), findsOneWidget);
    expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);
    expect(find.text('Flat 302, Royal Palms, Vaishali Nagar'), findsOneWidget);
    expect(find.text('Landmark: Near Central Mall'), findsOneWidget);
    expect(find.text('Jaipur, Rajasthan - 302021'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
    expect(find.text('-₹100'), findsOneWidget);
    expect(find.text('₹1,061'), findsWidgets);

    // 12. Tap back to return to My Bookings
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.byType(MyBookingsScreen), findsOneWidget);
    }
  });
}
