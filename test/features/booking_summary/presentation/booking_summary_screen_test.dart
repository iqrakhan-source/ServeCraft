import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/datasources/booking_summary_remote_data_source.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/booking_summary/data/repositories/booking_summary_repository_impl.dart';
import 'package:prop_crm/features/booking_summary/presentation/providers/booking_summary_provider.dart';
import 'package:prop_crm/features/booking_summary/presentation/screens/booking_summary_screen.dart';
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

  late MockBookingSummaryRemoteDataSource dataSource;
  late BookingSummaryRepositoryImpl repository;
  late BookingSummaryProvider provider;
  late MockPaymentRemoteDataSource paymentDataSource;
  late PaymentRepositoryImpl paymentRepository;
  late PaymentProvider paymentProvider;

  const service = ServiceModel(
    id: 'srv_1',
    categoryId: 'cat_1',
    name: 'Full Home Deep Clean',
    description: 'Deep house cleaning',
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

  final sampleSummary = BookingSummaryModel(
    service: service,
    package: package,
    address: address,
    scheduledDate: scheduledDate,
    timeSlot: timeSlot,
    pricing: PricingBreakdown.calculate(
      packagePrice: 999.0,
      discount: 100.0,
    ),
  );

  setUp(() {
    dataSource = MockBookingSummaryRemoteDataSource();
    repository = BookingSummaryRepositoryImpl(remoteDataSource: dataSource);
    provider = BookingSummaryProvider(repository: repository);
    paymentDataSource = MockPaymentRemoteDataSource();
    paymentRepository = PaymentRepositoryImpl(remoteDataSource: paymentDataSource);
    paymentProvider = PaymentProvider(repository: paymentRepository);
  });

  Widget buildTestApp(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookingSummaryProvider>.value(value: provider),
        ChangeNotifierProvider<PaymentProvider>.value(value: paymentProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('BookingSummaryScreen Widget Tests', () {
    testWidgets('Renders all review sections with full booking summary',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      provider.setSummary(sampleSummary);

      await tester.pumpWidget(
        buildTestApp(
          const BookingSummaryScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // 1. App Bar title
      expect(find.text('Review Booking'), findsOneWidget);

      // 2. Service section
      expect(find.text('Full Home Deep Clean'), findsOneWidget);
      expect(find.text('Premium 3BHK'), findsOneWidget);

      // 3. Schedule section
      expect(find.text('Scheduled Appointment'), findsOneWidget);
      expect(find.text('10:00 AM - 11:00 AM'), findsOneWidget);

      // 4. Address section
      expect(find.text('Service Address'), findsOneWidget);
      expect(find.text('Flat 302, Royal Palms, Vaishali Nagar'), findsOneWidget);
      expect(find.text('Jaipur, Rajasthan - 302021'), findsOneWidget);

      // 5. Price breakdown section
      expect(find.text('Price Details'), findsOneWidget);
      expect(find.text('Package Price'), findsOneWidget);
      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('Taxes & Fees'), findsOneWidget);
      expect(find.text('Total Amount'), findsWidgets);

      // 6. Bottom CTA button
      expect(find.widgetWithText(ElevatedButton, 'Continue to Payment'), findsOneWidget);
    });

    testWidgets('Tapping Continue to Payment navigates to payment screen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      provider.setSummary(sampleSummary);

      await tester.pumpWidget(
        buildTestApp(
          const BookingSummaryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final continueButton =
          find.widgetWithText(ElevatedButton, 'Continue to Payment');
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Should land on payment screen
      expect(find.byType(PaymentScreen), findsOneWidget);
      expect(find.text('Select Payment Method'), findsOneWidget);
    });

    testWidgets('Renders incomplete state when required booking items are missing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Do NOT set summary, leaving it empty
      await tester.pumpWidget(
        buildTestApp(
          const BookingSummaryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify incomplete state is shown
      expect(find.text('Booking Details Incomplete'), findsOneWidget);
      expect(
        find.text(
            'Some required booking information is missing. Please complete all previous steps before reviewing the summary.'),
        findsOneWidget,
      );
      expect(find.text('Go Back'), findsOneWidget);
    });
  });
}
