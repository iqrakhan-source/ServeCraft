import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:prop_crm/features/bookings/presentation/widgets/cancellation_reason_sheet.dart';
import 'package:provider/provider.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockBookingRemoteDataSource dataSource;
  late BookingRepositoryImpl repository;
  late BookingProvider provider;

  setUp(() {
    dataSource = MockBookingRemoteDataSource();
    repository = BookingRepositoryImpl(remoteDataSource: dataSource);
    provider = BookingProvider(repository: repository);
  });

  Widget buildApp() {
    return ChangeNotifierProvider<BookingProvider>.value(
      value: provider,
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const MyBookingsScreen(),
      ),
    );
  }

  testWidgets('End-to-End Booking Cancellation Flow: MyBookings -> Details -> Reason Sheet -> Cancelled state across app',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Launch My Bookings
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Verify initial state: Home Deep Cleaning is Confirmed
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Home Deep Cleaning'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);

    // 2. Tap on the confirmed booking card to navigate to Booking Details
    await tester.tap(find.text('Home Deep Cleaning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // Verify on BookingDetailsScreen
    expect(find.text('Booking Details'), findsOneWidget);
    expect(find.text('SC-2026-000101'), findsOneWidget);
    expect(find.text('Cancel Booking'), findsOneWidget);

    // 3. Tap Cancel Booking CTA
    await tester.tap(find.text('Cancel Booking'));
    await tester.pumpAndSettle();

    // Verify CancellationReasonSheet opened
    expect(find.textContaining('Are you sure you want to cancel this booking? This action cannot be undone.'), findsOneWidget);
    expect(find.text('Why are you cancelling?'), findsOneWidget);

    // 4. Select cancellation reason
    await tester.tap(find.text('Changed my plans'));
    await tester.pumpAndSettle();

    // 5. Confirm cancellation inside sheet
    final confirmBtn = find.descendant(
      of: find.byType(CancellationReasonSheet),
      matching: find.widgetWithText(ElevatedButton, 'Confirm Cancellation'),
    );
    await tester.tap(confirmBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 6. Verify SnackBar and updated BookingDetailsScreen
    expect(find.text('Booking cancelled successfully'), findsOneWidget);
    expect(find.textContaining('This booking was cancelled. Reason: Changed my plans.'), findsOneWidget);
    // Cancel Booking CTA must be gone
    expect(find.text('Cancel Booking'), findsNothing);

    // 7. Pop back to My Bookings Screen
    final backBtn = find.byType(BackButton);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
    } else {
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    }
    await tester.pumpAndSettle();

    // 8. Verify My Bookings Screen list synchronization
    expect(find.text('My Bookings'), findsOneWidget);

    // In 'All' tab: Home Deep Cleaning is now Cancelled
    expect(find.text('Home Deep Cleaning'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);

    // Switch to 'Upcoming' tab
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();

    // No upcoming bookings left -> should show empty state
    expect(find.text('No upcoming bookings yet'), findsOneWidget);
    expect(find.text('Home Deep Cleaning'), findsNothing);

    // Switch to 'Cancelled' tab
    await tester.tap(find.text('Cancelled'));
    await tester.pumpAndSettle();

    // Cancelled tab now contains Home Deep Cleaning
    expect(find.text('Home Deep Cleaning'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget); // Filter tab
  });
}
