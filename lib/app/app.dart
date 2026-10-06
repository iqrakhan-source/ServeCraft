import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config/app_config.dart';
import '../core/constants/route_names.dart';
import '../core/networking/api_service.dart';
import '../core/storage/storage_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/presentation/providers/category_provider.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/presentation/providers/home_provider.dart';
import '../features/services/domain/repositories/service_repository.dart';
import '../features/services/presentation/providers/service_details_provider.dart';
import '../features/addresses/domain/repositories/address_repository.dart';
import '../features/addresses/presentation/providers/address_provider.dart';
import '../features/date_time/domain/repositories/date_time_repository.dart';
import '../features/date_time/presentation/providers/date_time_provider.dart';
import '../features/booking_summary/domain/repositories/booking_summary_repository.dart';
import '../features/booking_summary/presentation/providers/booking_summary_provider.dart';
import '../features/bookings/domain/repositories/booking_repository.dart';
import '../features/bookings/presentation/providers/booking_provider.dart';
import '../features/payment/domain/repositories/payment_repository.dart';
import '../features/payment/presentation/providers/payment_provider.dart';
import '../features/services/presentation/providers/service_provider.dart';
import '../features/branches/domain/repositories/branch_repository.dart';
import '../features/branches/presentation/providers/branch_provider.dart';
import '../features/offers/presentation/providers/offer_provider.dart';
import 'app_router.dart';
import 'app_theme.dart';

class ServeCraftApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;
  final AuthRepository authRepository;
  final BranchRepository branchRepository;
  final CategoryRepository categoryRepository;
  final ServiceRepository serviceRepository;
  final HomeRepository homeRepository;
  final AddressRepository addressRepository;
  final DateTimeRepository dateTimeRepository;
  final BookingSummaryRepository bookingSummaryRepository;
  final PaymentRepository paymentRepository;
  final BookingRepository bookingRepository;

  const ServeCraftApp({
    super.key,
    required this.storageService,
    required this.apiService,
    required this.authRepository,
    required this.branchRepository,
    required this.categoryRepository,
    required this.serviceRepository,
    required this.homeRepository,
    required this.addressRepository,
    required this.dateTimeRepository,
    required this.bookingSummaryRepository,
    required this.paymentRepository,
    required this.bookingRepository,
  });

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.instance;

    return MultiProvider(
      providers: [
        // Core services & repositories injected into Provider tree
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<CategoryRepository>.value(value: categoryRepository),
        Provider<ServiceRepository>.value(value: serviceRepository),
        Provider<HomeRepository>.value(value: homeRepository),
        Provider<AddressRepository>.value(value: addressRepository),
        Provider<DateTimeRepository>.value(value: dateTimeRepository),
        Provider<BookingSummaryRepository>.value(value: bookingSummaryRepository),
        Provider<PaymentRepository>.value(value: paymentRepository),
        Provider<BookingRepository>.value(value: bookingRepository),
        Provider<BranchRepository>.value(value: branchRepository),

        // Branch Provider
        ChangeNotifierProvider<BranchProvider>(
          create: (_) => BranchProvider(
            repository: branchRepository,
            storageService: storageService,
          ),
        ),

        // Offer & Coupon Provider
        ChangeNotifierProvider<OfferProvider>(
          create: (_) => OfferProvider(),
        ),

        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(repository: authRepository),
        ),

        // Category Provider
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(repository: categoryRepository),
        ),

        // Service Listing & Search Provider
        ChangeNotifierProvider<ServiceProvider>(
          create: (_) => ServiceProvider(repository: serviceRepository),
        ),

        // Service Details & Package Provider
        ChangeNotifierProvider<ServiceDetailsProvider>(
          create: (_) =>
              ServiceDetailsProvider(repository: serviceRepository),
        ),

        // Home Aggregator Provider
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(repository: homeRepository),
        ),

        // Address Management & Selection Provider
        ChangeNotifierProvider<AddressProvider>(
          create: (_) => AddressProvider(repository: addressRepository),
        ),

        // Date & Time Selection Provider
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) => DateTimeProvider(repository: dateTimeRepository),
        ),

        // Booking Summary Provider
        ChangeNotifierProvider<BookingSummaryProvider>(
          create: (_) =>
              BookingSummaryProvider(repository: bookingSummaryRepository),
        ),

        // Payment Provider
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(repository: paymentRepository),
        ),

        // Booking Provider
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(repository: bookingRepository),
        ),
      ],
      child: MaterialApp(
        title: appConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
