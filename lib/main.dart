import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/constants/api_constants.dart';
import 'core/networking/api_client.dart';
import 'core/storage/shared_prefs_storage_service.dart';
import 'core/storage/storage_keys.dart';
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
import 'features/offers/data/repositories/coupon_repository_impl.dart';
import 'features/offers/datasources/coupon_remote_data_source.dart';
import 'features/offers/domain/repositories/coupon_repository.dart';
import 'features/payment/data/datasources/payment_remote_data_source.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/date_time/data/datasources/date_time_remote_data_source.dart';
import 'features/date_time/data/repositories/date_time_repository_impl.dart';
import 'features/date_time/domain/repositories/date_time_repository.dart';
import 'features/branches/data/datasources/branch_remote_data_source.dart';
import 'features/branches/data/repositories/branch_repository_impl.dart';
import 'features/branches/domain/repositories/branch_repository.dart';
import 'features/services/data/datasources/service_remote_data_source.dart';
import 'features/services/data/repositories/service_repository_impl.dart';
import 'package:prop_crm/features/services/data/datasources/service_products_remote_data_source.dart';
import 'features/subscriptions/data/datasources/subscription_remote_data_source.dart';
import 'features/subscriptions/data/repositories/subscription_repository.dart';
import 'features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'features/loyalty/domain/repositories/loyalty_repository.dart';
import 'features/waitlist/data/datasources/waitlist_remote_data_source.dart';
import 'features/waitlist/data/repositories/waitlist_repository_impl.dart';
import 'features/waitlist/domain/repositories/waitlist_repository.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/stylists/data/datasources/stylist_remote_data_source.dart';
import 'features/stylists/data/repositories/stylist_repository_impl.dart';
import 'features/stylists/domain/repositories/stylist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize environment configuration
  AppConfig.initialize(
    config: const AppConfig(
      environment: AppEnvironment.development,
      appName: 'Luxe Salon & Spa',
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
      storageService.remove(StorageKeys.authToken);
      storageService.remove(StorageKeys.refreshToken);
      storageService.remove(StorageKeys.userId);
      storageService.remove(StorageKeys.userPhone);
      storageService.remove(StorageKeys.isProfileComplete);
      storageService.remove(StorageKeys.userCachedJson);
    },
  );

  // 4. Initialize Data Sources & Repositories
  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSourceImpl(
    apiService: apiClient,
    storageService: storageService,
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: storageService,
  );

  final BranchRemoteDataSource branchRemoteDataSource =
      BranchRemoteDataSourceImpl(apiService: apiClient);
  final BranchRepository branchRepository = BranchRepositoryImpl(
    remoteDataSource: branchRemoteDataSource,
  );

  final CategoryRemoteDataSource categoryRemoteDataSource =
      CategoryRemoteDataSourceImpl(apiService: apiClient);
  final CategoryRepository categoryRepository = CategoryRepositoryImpl(
    remoteDataSource: categoryRemoteDataSource,
  );

  final ServiceRemoteDataSource serviceRemoteDataSource =
      ServiceRemoteDataSourceImpl(apiService: apiClient);

  final serviceRepository = ServiceRepositoryImpl(
    remoteDataSource: serviceRemoteDataSource,
    productsRemoteDataSource: ServiceProductsRemoteDataSourceImpl(
      apiService: apiClient,
    ),
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
      DateTimeRemoteDataSourceImpl(apiService: apiClient);
  final DateTimeRepository dateTimeRepository = DateTimeRepositoryImpl(
    remoteDataSource: dateTimeRemoteDataSource,
  );

  final CouponRemoteDataSource couponRemoteDataSource =
      CouponRemoteDataSourceImpl(apiClient: apiClient);
  final CouponRepository couponRepository = CouponRepositoryImpl(
    remoteDataSource: couponRemoteDataSource,
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
      BookingRemoteDataSourceImpl(apiService: apiClient);
  final BookingRepository bookingRepository = BookingRepositoryImpl(
    remoteDataSource: bookingRemoteDataSource,
  );

  final SubscriptionRemoteDataSource subscriptionRemoteDataSource =
      SubscriptionRemoteDataSourceImpl(apiClient: apiClient);
  final SubscriptionRepository subscriptionRepository =
      SubscriptionRepositoryImpl(
        remoteDataSource: subscriptionRemoteDataSource,
      );

  final LoyaltyRemoteDataSource loyaltyRemoteDataSource =
      LoyaltyRemoteDataSourceImpl(apiService: apiClient);
  final LoyaltyRepository loyaltyRepository = LoyaltyRepositoryImpl(
    remoteDataSource: loyaltyRemoteDataSource,
  );

  final WaitlistRemoteDataSource waitlistRemoteDataSource =
      WaitlistRemoteDataSourceImpl(apiClient: apiClient);
  final WaitlistRepository waitlistRepository = WaitlistRepositoryImpl(
    remoteDataSource: waitlistRemoteDataSource,
  );

  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl(apiClient: apiClient);
  final NotificationRepository notificationRepository =
      NotificationRepositoryImpl(
        remoteDataSource: notificationRemoteDataSource,
      );

  final StylistRemoteDataSource stylistRemoteDataSource =
      StylistRemoteDataSourceImpl(apiClient: apiClient);
  final StylistRepository stylistRepository = StylistRepositoryImpl(
    remoteDataSource: stylistRemoteDataSource,
  );

  // 5. Launch application
  runApp(
    ServeCraftApp(
      storageService: storageService,
      authRepository: authRepository,
      branchRepository: branchRepository,
      categoryRepository: categoryRepository,
      serviceRepository: serviceRepository,
      homeRepository: homeRepository,
      addressRepository: addressRepository,
      dateTimeRepository: dateTimeRepository,
      bookingSummaryRepository: bookingSummaryRepository,
      paymentRepository: paymentRepository,
      bookingRepository: bookingRepository,
      couponRepository: couponRepository,
      subscriptionRepository: subscriptionRepository,
      loyaltyRepository: loyaltyRepository,
      waitlistRepository: waitlistRepository,
      notificationRepository: notificationRepository,
      stylistRepository: stylistRepository,
    ),
  );
}
