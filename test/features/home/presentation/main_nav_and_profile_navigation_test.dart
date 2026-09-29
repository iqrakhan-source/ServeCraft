import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:prop_crm/features/auth/presentation/screens/profile_screen.dart';
import 'package:prop_crm/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:prop_crm/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:prop_crm/features/bookings/presentation/providers/booking_provider.dart';
import 'package:prop_crm/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:prop_crm/features/categories/data/repositories/category_repository_impl.dart';
import 'package:prop_crm/features/categories/presentation/providers/category_provider.dart';
import 'package:prop_crm/features/home/data/datasources/home_remote_data_source.dart';
import 'package:prop_crm/features/home/data/repositories/home_repository_impl.dart';
import 'package:prop_crm/features/home/presentation/providers/home_provider.dart';
import 'package:prop_crm/features/home/presentation/screens/main_nav_screen.dart';
import 'package:prop_crm/features/services/data/datasources/service_remote_data_source.dart';
import 'package:prop_crm/features/services/data/repositories/service_repository_impl.dart';
import 'package:prop_crm/features/services/presentation/providers/service_details_provider.dart';
import 'package:prop_crm/features/services/presentation/providers/service_provider.dart';
import 'package:provider/provider.dart';
import '../../../mocks/fake_storage_service.dart';
import '../../../mocks/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late FakeStorageService storageService;
  late MockAuthRemoteDataSource authDataSource;
  late AuthRepositoryImpl authRepository;
  late AuthProvider authProvider;

  late MockCategoryRemoteDataSource categoryDataSource;
  late CategoryRepositoryImpl categoryRepository;
  late CategoryProvider categoryProvider;

  late MockServiceRemoteDataSource serviceDataSource;
  late ServiceRepositoryImpl serviceRepository;
  late ServiceProvider serviceProvider;
  late ServiceDetailsProvider serviceDetailsProvider;

  late MockHomeRemoteDataSource homeDataSource;
  late HomeRepositoryImpl homeRepository;
  late HomeProvider homeProvider;

  late MockBookingRemoteDataSource bookingDataSource;
  late BookingRepositoryImpl bookingRepository;
  late BookingProvider bookingProvider;

  setUp(() async {
    storageService = FakeStorageService();
    authDataSource = MockAuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authDataSource,
      storageService: storageService,
    );
    authProvider = AuthProvider(repository: authRepository);

    await authProvider.sendOtp('9876543299');
    await authProvider.verifyOtp('123456');

    categoryDataSource = MockCategoryRemoteDataSource();
    categoryRepository = CategoryRepositoryImpl(remoteDataSource: categoryDataSource);
    categoryProvider = CategoryProvider(repository: categoryRepository);

    serviceDataSource = MockServiceRemoteDataSource();
    serviceRepository = ServiceRepositoryImpl(remoteDataSource: serviceDataSource);
    serviceProvider = ServiceProvider(repository: serviceRepository);
    serviceDetailsProvider = ServiceDetailsProvider(repository: serviceRepository);

    homeDataSource = MockHomeRemoteDataSource(
      categoryDataSource: categoryDataSource,
      serviceDataSource: serviceDataSource,
    );
    homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
    homeProvider = HomeProvider(repository: homeRepository);

    bookingDataSource = MockBookingRemoteDataSource();
    bookingRepository = BookingRepositoryImpl(remoteDataSource: bookingDataSource);
    bookingProvider = BookingProvider(repository: bookingRepository);
  });

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
        ChangeNotifierProvider<ServiceProvider>.value(value: serviceProvider),
        ChangeNotifierProvider<ServiceDetailsProvider>.value(value: serviceDetailsProvider),
        ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
        ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
      ],
      child: const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: MainNavScreen(),
      ),
    );
  }

  group('Main Navigation & Dashboard Profile Flow Tests', () {
    testWidgets('Dashboard app-bar profile icon exists and navigates to ProfileScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // Verify SC branding and location on left
      expect(find.text('SC'), findsWidgets);
      expect(find.text('Home'), findsWidgets);

      // Verify notification bell and profile icon exist in header
      expect(find.byKey(const Key('dashboard_notification_button')), findsOneWidget);
      final profileIcon = find.byKey(const Key('dashboard_profile_button'));
      expect(profileIcon, findsOneWidget);

      // Tap profile icon
      await tester.tap(profileIcon);
      await tester.pumpAndSettle();

      // Verify ProfileScreen is reached
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
    });

    testWidgets('Bottom navigation contains exactly 4 intended destinations and Profile is NOT in bottom nav',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      final bottomNavBarFinder = find.byType(BottomNavigationBar);
      expect(bottomNavBarFinder, findsOneWidget);

      final bottomNavBar = tester.widget<BottomNavigationBar>(bottomNavBarFinder);
      expect(bottomNavBar.items.length, 4);

      // Verify labels
      expect(bottomNavBar.items[0].label, 'Dashboard');
      expect(bottomNavBar.items[1].label, 'Referral');
      expect(bottomNavBar.items[2].label, 'Bookings');
      expect(bottomNavBar.items[3].label, 'Offers');

      // Verify Profile is not among bottom navigation items
      final labels = bottomNavBar.items.map((i) => i.label).toList();
      expect(labels.contains('Profile'), isFalse);
    });

    testWidgets('Tapping Bookings tab opens My Bookings', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // Tap Bookings tab
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();

      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('Tapping Referral tab displays Referral destination', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // Tap Referral tab
      await tester.tap(find.text('Referral'));
      await tester.pumpAndSettle();

      expect(find.text('Referral Program'), findsOneWidget);
      expect(find.textContaining('Invite friends & neighbors to ServeCraft'), findsOneWidget);
    });

    testWidgets('Responsive testing at 360px, 390px, and 412px with zero overflows',
        (tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Referral'), findsOneWidget);
        expect(find.text('Bookings'), findsOneWidget);
        expect(find.text('Offers'), findsOneWidget);

        // Header elements must fit without overflow
        expect(find.byKey(const Key('dashboard_notification_button')), findsOneWidget);
        expect(find.byKey(const Key('dashboard_profile_button')), findsOneWidget);

        final exception = tester.takeException();
        expect(exception, isNull);
      }

      tester.view.resetPhysicalSize();
    });
  });
}
