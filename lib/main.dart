import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/constants/api_constants.dart';
import 'core/networking/api_client.dart';
import 'core/networking/api_service.dart';
import 'core/storage/shared_prefs_storage_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/categories/data/datasources/category_remote_data_source.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/addresses/data/datasources/address_remote_data_source.dart';
import 'features/addresses/data/repositories/address_repository_impl.dart';
import 'features/addresses/domain/repositories/address_repository.dart';
import 'features/booking_summary/data/datasources/booking_summary_remote_data_source.dart';
import 'features/booking_summary/data/repositories/booking_summary_repository_impl.dart';
import 'features/booking_summary/domain/repositories/booking_summary_repository.dart';
import 'features/bookings/data/datasources/booking_remote_data_source.dart';
import 'features/bookings/data/repositories/booking_repository_impl.dart';
import 'features/bookings/domain/repositories/booking_repository.dart';
import 'features/payment/data/datasources/payment_remote_data_source.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/date_time/data/datasources/date_time_remote_data_source.dart';
import 'features/date_time/data/repositories/date_time_repository_impl.dart';
import 'features/date_time/domain/repositories/date_time_repository.dart';
import 'features/services/data/datasources/service_remote_data_source.dart';
import 'features/services/data/repositories/service_repository_impl.dart';
import 'features/services/domain/repositories/service_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize environment configuration
  AppConfig.initialize(
    config: const AppConfig(
      environment: AppEnvironment.development,
      appName: 'ServeCraft',
      appVersion: '1.0.0',
      apiBaseUrl: ApiConstants.defaultBaseUrl,
      enableLogging: true,
      enablePromoOffers: true,
    ),
  );

  // 2. Initialize local storage
  final storageService = SharedPrefsStorageService();
  await storageService.init();

  // 3. Initialize network client and API service
  final apiClient = ApiClient.create(
    storageService: storageService,
    onUnauthorized: () {
      // Session invalidation hook for 401
    },
  );
  final apiService = DioApiService(dio: apiClient.dio);

  // 4. Initialize Data Sources & Repositories
  // TEMPORARY: Isolated Mock Data Source until backend API contract is deployed.
  // To switch to live API, simply replace mock instances with *RemoteDataSourceImpl(apiService: apiService)
  final AuthRemoteDataSource authRemoteDataSource = MockAuthRemoteDataSource();
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: storageService,
  );

  final CategoryRemoteDataSource categoryRemoteDataSource =
      MockCategoryRemoteDataSource();
  final CategoryRepository categoryRepository = CategoryRepositoryImpl(
    remoteDataSource: categoryRemoteDataSource,
  );

  final ServiceRemoteDataSource serviceRemoteDataSource =
      MockServiceRemoteDataSource();
  final ServiceRepository serviceRepository = ServiceRepositoryImpl(
    remoteDataSource: serviceRemoteDataSource,
  );

  final HomeRemoteDataSource homeRemoteDataSource = MockHomeRemoteDataSource(
    categoryDataSource: categoryRemoteDataSource,
    serviceDataSource: serviceRemoteDataSource,
  );
  final HomeRepository homeRepository = HomeRepositoryImpl(
    remoteDataSource: homeRemoteDataSource,
  );

  final AddressRemoteDataSource addressRemoteDataSource =
      MockAddressRemoteDataSource();
  final AddressRepository addressRepository = AddressRepositoryImpl(
    remoteDataSource: addressRemoteDataSource,
  );

  final DateTimeRemoteDataSource dateTimeRemoteDataSource =
      MockDateTimeRemoteDataSource();
  final DateTimeRepository dateTimeRepository = DateTimeRepositoryImpl(
    remoteDataSource: dateTimeRemoteDataSource,
  );

  final BookingSummaryRemoteDataSource bookingSummaryRemoteDataSource =
      MockBookingSummaryRemoteDataSource();
  final BookingSummaryRepository bookingSummaryRepository =
      BookingSummaryRepositoryImpl(
    remoteDataSource: bookingSummaryRemoteDataSource,
  );

  final PaymentRemoteDataSource paymentRemoteDataSource =
      MockPaymentRemoteDataSource();
  final PaymentRepository paymentRepository = PaymentRepositoryImpl(
    remoteDataSource: paymentRemoteDataSource,
  );

  final BookingRemoteDataSource bookingRemoteDataSource =
      MockBookingRemoteDataSource();
  final BookingRepository bookingRepository = BookingRepositoryImpl(
    remoteDataSource: bookingRemoteDataSource,
  );

  // 5. Launch application
  runApp(
    ServeCraftApp(
      storageService: storageService,
      apiService: apiService,
      authRepository: authRepository,
      categoryRepository: categoryRepository,
      serviceRepository: serviceRepository,
      homeRepository: homeRepository,
      addressRepository: addressRepository,
      dateTimeRepository: dateTimeRepository,
      bookingSummaryRepository: bookingSummaryRepository,
      paymentRepository: paymentRepository,
      bookingRepository: bookingRepository,
    ),
  );
}
