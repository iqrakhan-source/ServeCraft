abstract class AppRoutes {
  static const String splash = '/';
  
  // Auth flow
  static const String mobileLogin = '/auth/login';
  static const String otpVerification = '/auth/otp';
  static const String completeProfile = '/auth/complete-profile';

  // Main navigation & Tabs
  static const String mainNav = '/main';
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String offers = '/offers';
  static const String profile = '/profile';

  // Categories & Services
  static const String categories = '/categories';
  static const String serviceListing = '/services/listing';
  static const String serviceDetails = '/services/details';
  static const String packageSelection = '/services/packages';

  // Addresses & Checkout
  static const String addressSelection = '/checkout/addresses';
  static const String addAddress = '/checkout/addresses/add';
  static const String dateTimeSelection = '/checkout/date-time';
  static const String bookingSummary = '/checkout/summary';
  static const String payment = '/checkout/payment';
  static const String bookingConfirmation = '/checkout/confirmation';

  // Bookings & Tracking
  static const String myBookings = '/bookings/my-bookings';
  static const String bookingDetails = '/bookings/details';

  // Profile & Reviews
  static const String editProfile = '/profile/edit';
  static const String reviews = '/reviews';
  static const String addReview = '/reviews/add';
}
