import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/app/app_router.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:prop_crm/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:prop_crm/features/categories/data/repositories/category_repository_impl.dart';
import 'package:prop_crm/features/categories/presentation/providers/category_provider.dart';
import 'package:prop_crm/features/categories/presentation/screens/categories_screen.dart';
import 'package:prop_crm/features/home/data/datasources/home_remote_data_source.dart';
import 'package:prop_crm/features/home/data/repositories/home_repository_impl.dart';
import 'package:prop_crm/features/home/presentation/providers/home_provider.dart';
import 'package:prop_crm/features/home/presentation/screens/home_screen.dart';
import 'package:prop_crm/features/services/data/datasources/service_remote_data_source.dart';
import 'package:prop_crm/features/services/data/repositories/service_repository_impl.dart';
import 'package:prop_crm/features/services/presentation/providers/service_details_provider.dart';
import 'package:prop_crm/features/services/presentation/providers/service_provider.dart';
import 'package:prop_crm/features/services/presentation/screens/service_details_screen.dart';
import 'package:prop_crm/features/services/presentation/screens/service_listing_screen.dart';
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

  setUp(() async {
    storageService = FakeStorageService();
    authDataSource = MockAuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authDataSource,
      storageService: storageService,
    );
    authProvider = AuthProvider(repository: authRepository);

    // Establish active authenticated session
    await authProvider.sendOtp('9876543299');
    await authProvider.verifyOtp('123456');

    categoryDataSource = MockCategoryRemoteDataSource();
    categoryRepository =
        CategoryRepositoryImpl(remoteDataSource: categoryDataSource);
    categoryProvider = CategoryProvider(repository: categoryRepository);

    serviceDataSource = MockServiceRemoteDataSource();
    serviceRepository =
        ServiceRepositoryImpl(remoteDataSource: serviceDataSource);
    serviceProvider = ServiceProvider(repository: serviceRepository);
    serviceDetailsProvider =
        ServiceDetailsProvider(repository: serviceRepository);

    homeDataSource = MockHomeRemoteDataSource(
      categoryDataSource: categoryDataSource,
      serviceDataSource: serviceDataSource,
    );
    homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
    homeProvider = HomeProvider(repository: homeRepository);
  });

  Widget buildTestApp(Widget homeWidget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
        ChangeNotifierProvider<ServiceProvider>.value(value: serviceProvider),
        ChangeNotifierProvider<ServiceDetailsProvider>.value(
            value: serviceDetailsProvider),
        ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: homeWidget,
      ),
    );
  }

  group('Phase 3 Consumer Experience Screen & Flow Tests', () {
    testWidgets('HomeScreen renders greeting, location, search, banners, categories, and services',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      // Advance frames and mock timers (350ms home + 300ms cat + 300ms srv = 950ms)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      // 1. Location summary & header
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Home • Indiranagar, Bengaluru'), findsOneWidget);

      // 2. Search field placeholder
      expect(find.text('Search for a service'), findsOneWidget);

      // 3. Section titles
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Popular Services'), findsOneWidget);
      expect(find.text('ServeCraft Quality Assurance'), findsOneWidget);

      // 4. Category items loaded
      expect(find.text('Home Cleaning'), findsOneWidget);
    });

    testWidgets('CategoriesScreen displays all categories and navigates to service listing on tap',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(const CategoriesScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('Home Cleaning'), findsOneWidget);
      expect(find.text('Appliance Repair'), findsOneWidget);

      // Tap on a category card
      await tester.tap(find.text('Home Cleaning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Navigated to ServiceListingScreen
      expect(find.byType(ServiceListingScreen), findsOneWidget);
      expect(find.text('Home Cleaning'), findsWidgets);
    });

    testWidgets('ServiceListingScreen filters services by category and supports search query',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(const ServiceListingScreen(
          categoryId: 'cat_cleaning',
          categoryName: 'Home Cleaning',
        )),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Home Cleaning'), findsWidgets);

      // Check service items present
      expect(find.text('Full Home Deep Cleaning'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Degreasing');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Kitchen service matches
      expect(find.text('Kitchen Deep Degreasing'), findsOneWidget);
      expect(find.text('Full Home Deep Cleaning'), findsNothing);

      // Tap the filtered service to navigate to ServiceDetailsScreen
      await tester.tap(find.text('Kitchen Deep Degreasing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify ServiceDetailsScreen is pushed
      expect(find.byType(ServiceDetailsScreen), findsOneWidget);
    });

    testWidgets('ServiceDetailsScreen renders service details, packages, and CTA button',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(const ServiceDetailsScreen(serviceId: 'srv_ac_service')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify details displayed
      expect(find.text('AC Master Servicing (Foam-Jet)'), findsWidgets);
      expect(find.text('About Service'), findsOneWidget);
      expect(find.text('Available Packages'), findsOneWidget);
      expect(find.text('ServeCraft Verified Experts'), findsOneWidget);

      // Verify package selection
      expect(find.text('Split AC Power Jet Clean'), findsOneWidget);

      // CTA button displayed with selected package
      expect(find.text('Select Split AC Power Jet Clean'), findsOneWidget);

      // Tap CTA button - navigates to packageSelection placeholder route
      await tester.tap(find.text('Select Split AC Power Jet Clean'));
      await tester.pumpAndSettle();

      expect(find.text('Package Selection'), findsWidgets);
      expect(find.text('Scheduled for Phase 4: Booking Flow'), findsOneWidget);
    });
  });
}
