import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/widgets/cancellation_reason_sheet.dart';
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
    id: 'bk_seed_001',
    bookingReference: 'SC-2026-000101',
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
      features: ['Deep wash'],
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

  Widget buildTestHost({required Widget child}) {
    return ChangeNotifierProvider<BookingProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('CancellationReasonSheet Widget Tests', () {
    testWidgets('Renders all sheet contents and default reasons', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestHost(
          child: CancellationReasonSheet(booking: sampleBooking),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsNWidgets(2)); // Title and Button
      expect(find.text('Full Home Deep Clean'), findsOneWidget);
      expect(find.text('Changed my plans'), findsOneWidget);
      expect(find.text('Booked by mistake'), findsOneWidget);
      expect(find.text('Found another service'), findsOneWidget);
      expect(find.text('Schedule no longer works'), findsOneWidget);
      expect(find.text('Service no longer required'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Keep Booking'), findsOneWidget);
    });

    testWidgets('Cancel button is disabled until a reason is selected', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestHost(
          child: CancellationReasonSheet(booking: sampleBooking),
        ),
      );
      await tester.pumpAndSettle();

      // Before selecting a reason:
      // Tapping Cancel Booking should not trigger any action
      final cancelBtnFinder = find.widgetWithText(ElevatedButton, 'Cancel Booking');
      expect(cancelBtnFinder, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(cancelBtnFinder);
      expect(elevatedButton.onPressed, isNull);

      // Select 'Changed my plans'
      await tester.tap(find.text('Changed my plans'));
      await tester.pumpAndSettle();

      // Now button should be enabled
      final updatedBtn = tester.widget<ElevatedButton>(cancelBtnFinder);
      expect(updatedBtn.onPressed, isNotNull);
    });

    testWidgets('Selecting Other reveals note text field', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestHost(
          child: CancellationReasonSheet(booking: sampleBooking),
        ),
      );
      await tester.pumpAndSettle();

      // Note field should not be visible initially
      expect(find.text('Additional Details (Optional)'), findsNothing);

      // Tap 'Other'
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();

      // Now note field is visible
      expect(find.text('Additional Details (Optional)'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Selecting reason and confirming cancels booking and dismisses sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? result;
      await tester.pumpWidget(
        buildTestHost(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await CancellationReasonSheet.show(context, booking: sampleBooking);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Select reason
      await tester.tap(find.text('Changed my plans'));
      await tester.pumpAndSettle();

      // Tap Cancel Booking
      final cancelBtnFinder = find.widgetWithText(ElevatedButton, 'Cancel Booking');
      await tester.tap(cancelBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Sheet dismissed and returned true
      expect(result, isTrue);
      expect(provider.cancellationState.isSuccess, isTrue);
    });

    testWidgets('Keep Booking button dismisses sheet without cancelling', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? result;
      await tester.pumpWidget(
        buildTestHost(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await CancellationReasonSheet.show(context, booking: sampleBooking);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Keep Booking
      await tester.tap(find.text('Keep Booking'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(provider.cancellationState.isInitial, isTrue);
    });

    testWidgets('Displays inline error banner when cancellation fails', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      dataSource.shouldFail = true;

      await tester.pumpWidget(
        buildTestHost(
          child: CancellationReasonSheet(booking: sampleBooking),
        ),
      );
      await tester.pumpAndSettle();

      // Select reason
      await tester.tap(find.text('Changed my plans'));
      await tester.pumpAndSettle();

      // Tap Cancel Booking
      final cancelBtnFinder = find.widgetWithText(ElevatedButton, 'Cancel Booking');
      await tester.tap(cancelBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Error message should be displayed inline
      expect(provider.cancellationState.isError, isTrue);
      expect(find.textContaining("Couldn't cancel this booking"), findsOneWidget);
    });
  });
}
