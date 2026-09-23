import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/route_names.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/custom_app_bar.dart';
import '../features/auth/presentation/screens/complete_profile_screen.dart';
import '../features/auth/presentation/screens/mobile_login_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/addresses/data/models/address_model.dart';
import '../features/addresses/presentation/screens/add_address_screen.dart';
import '../features/addresses/presentation/screens/addresses_screen.dart';
import '../features/categories/presentation/screens/categories_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/main_nav_screen.dart';
import '../features/services/presentation/screens/service_details_screen.dart';
import '../features/services/presentation/screens/service_listing_screen.dart';
import '../features/date_time/presentation/screens/date_time_selection_screen.dart';
import '../features/date_time/data/models/service_date_model.dart';
import '../features/date_time/data/models/time_slot_model.dart';
import '../features/services/data/models/service_model.dart';
import '../features/services/data/models/service_package_model.dart';
import '../features/booking_summary/data/models/booking_summary_model.dart';
import '../features/booking_summary/presentation/screens/booking_summary_screen.dart';
import '../features/bookings/data/models/booking_model.dart';
import '../features/bookings/presentation/screens/booking_confirmation_screen.dart';
import '../features/bookings/presentation/screens/booking_details_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.mobileLogin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MobileLoginScreen(),
        );

      case AppRoutes.otpVerification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationScreen(
            phone: settings.arguments as String?,
          ),
        );

      case AppRoutes.completeProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CompleteProfileScreen(),
        );

      case AppRoutes.mainNav:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavScreen(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.categories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategoriesScreen(),
        );

      case AppRoutes.serviceListing: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ServiceListingScreen(
            categoryId: args?['categoryId'] as String?,
            categoryName: args?['categoryName'] as String?,
          ),
        );
      }

      case AppRoutes.serviceDetails: {
        final args = settings.arguments as Map<String, dynamic>?;
        final serviceId = args?['serviceId'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ServiceDetailsScreen(
            serviceId: serviceId,
          ),
        );
      }

      case AppRoutes.packageSelection:
        return _buildPlaceholderRoute(
          settings: settings,
          title: 'Package Selection',
          phaseName: 'Phase 4: Booking Flow',
        );

      case AppRoutes.addressSelection: {
        final args = settings.arguments as Map<String, dynamic>?;
        final isSelectionMode = args?['isSelectionMode'] as bool? ?? true;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddressesScreen(
            isSelectionMode: isSelectionMode,
          ),
        );
      }

      case AppRoutes.addAddress: {
        final args = settings.arguments as Map<String, dynamic>?;
        final existingAddress = args?['existingAddress'] as AddressModel?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddAddressScreen(
            existingAddress: existingAddress,
          ),
        );
      }

      case AppRoutes.dateTimeSelection: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DateTimeSelectionScreen(
            serviceId: args?['serviceId'] as String?,
            serviceName: args?['serviceName'] as String?,
            packageId: args?['packageId'] as String?,
            packageName: args?['packageName'] as String?,
          ),
        );
      }

      case AppRoutes.bookingSummary: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingSummaryScreen(
            service: args?['service'] as ServiceModel?,
            package: args?['package'] as ServicePackageModel?,
            address: args?['address'] as AddressModel?,
            scheduledDate: args?['scheduledDate'] as ServiceDateModel?,
            timeSlot: args?['timeSlot'] as TimeSlotModel?,
            initialSummary: args?['bookingSummary'] as BookingSummaryModel?,
          ),
        );
      }

      case AppRoutes.payment: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PaymentScreen(
            bookingSummary: args?['bookingSummary'] as BookingSummaryModel?,
          ),
        );
      }

      case AppRoutes.bookingConfirmation: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingConfirmationScreen(
            booking: args?['booking'] as BookingModel?,
          ),
        );
      }

      case AppRoutes.bookings:
      case AppRoutes.myBookings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyBookingsScreen(),
        );

      case AppRoutes.bookingDetails: {
        final args = settings.arguments as Map<String, dynamic>?;
        final bookingId = args?['bookingId'] as String? ?? '';
        final initialBooking = args?['booking'] as BookingModel?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BookingDetailsScreen(
            bookingId: bookingId,
            initialBooking: initialBooking,
          ),
        );
      }

      case AppRoutes.profile:
      case AppRoutes.editProfile:
        return _buildPlaceholderRoute(
          settings: settings,
          title: 'Profile & Settings',
          phaseName: 'Phase 7: Profile & Reviews',
        );

      case AppRoutes.reviews:
      case AppRoutes.addReview:
        return _buildPlaceholderRoute(
          settings: settings,
          title: 'Reviews',
          phaseName: 'Phase 7: Profile & Reviews',
        );

      case AppRoutes.offers:
        return _buildPlaceholderRoute(
          settings: settings,
          title: 'Offers & Discounts',
          phaseName: 'Phase 7: Offers',
        );

      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static MaterialPageRoute _buildPlaceholderRoute({
    required RouteSettings settings,
    required String title,
    required String phaseName,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: CustomAppBar(title: title),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.construction_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scheduled for $phaseName',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Back',
                  isFullWidth: false,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static MaterialPageRoute _buildNotFoundRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: const CustomAppBar(title: 'Page Not Found'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('404 - Not Found', style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Route "${settings.name}" does not exist.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Return Home',
                  isFullWidth: false,
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
