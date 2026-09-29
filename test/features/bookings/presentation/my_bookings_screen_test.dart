import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/domain/repositories/booking_repository.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/bookings/presentation/screens/booking_details_screen.dart';
import 'package:prop_crm/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:prop_crm/features/bookings/presentation/widgets/booking_card.dart';
import 'package:prop_crm/features/bookings/presentation/widgets/booking_card_skeleton.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
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

  Widget buildTestApp(Widget screen) {
    return ChangeNotifierProvider<BookingProvider>.value(
      value: provider,
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: screen,
      ),
    );
  }

  group('MyBookingsScreen Widget Tests', () {
    testWidgets('Renders title, filter tabs, and seeded booking cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));

      // Initial frame trigger post frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('My Bookings'), findsOneWidget);

      // Filter tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // 2 seeded bookings rendered
      expect(find.byType(BookingCard), findsNWidgets(2));
      expect(find.text('Home Deep Cleaning'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Kitchen Deep Cleaning'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('Filtering tabs update displayed booking cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Tap Upcoming tab
      await tester.tap(find.text('Upcoming'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsOneWidget);
      expect(find.text('Home Deep Cleaning'), findsOneWidget);
      expect(find.text('Kitchen Deep Cleaning'), findsNothing);

      // Tap Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsOneWidget);
      expect(find.text('Kitchen Deep Cleaning'), findsOneWidget);
      expect(find.text('Home Deep Cleaning'), findsNothing);

      // Tap Cancelled tab (empty)
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsNothing);
      expect(find.text('No cancelled bookings yet'), findsOneWidget);

      // Tap back to All tab
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsNWidgets(2));
    });

    testWidgets('Renders overall empty state when no bookings exist', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final emptyProvider = BookingProvider(repository: _EmptyBookingRepository());

      await tester.pumpWidget(
        ChangeNotifierProvider<BookingProvider>.value(
          value: emptyProvider,
          child: const MaterialApp(
            home: MyBookingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('No bookings yet'), findsOneWidget);
      expect(find.text('Your booked services will appear here.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Explore Services'), findsOneWidget);
    });

    testWidgets('Renders loading skeleton while bookings are being fetched', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));

      // Post-frame callback fired, provider is now in loading state
      await tester.pump();
      expect(provider.isLoadingBookings, isTrue);
      expect(find.byType(BookingCardSkeleton), findsWidgets);

      // Advance through network delay
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsNWidgets(2));
    });

    testWidgets('Renders error state with retry button on fetch failure', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      dataSource.shouldFail = true;

      await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load your bookings"), findsOneWidget);
      final retryButton = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryButton, findsOneWidget);

      // Unset failure and tap retry
      dataSource.shouldFail = false;
      await tester.tap(retryButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsNWidgets(2));
    });

    testWidgets('Tapping booking card navigates to BookingDetailsScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Tap on first booking card
      await tester.tap(find.text('Home Deep Cleaning'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('SC-2026-000101'), findsOneWidget);
    });

    testWidgets('Responsive layouts render cleanly without overflow at 360, 390, 412px',
        (tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestApp(const MyBookingsScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        expect(find.text('My Bookings'), findsOneWidget);
        expect(find.byType(BookingCard), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      }

      tester.view.resetPhysicalSize();
    });
  });
}

class _EmptyBookingRepository implements BookingRepository {
  @override
  Future<List<BookingModel>> getBookings() async => [];

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    throw Exception('Not found');
  }

  @override
  Future<BookingModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    throw UnimplementedError();
  }
}
