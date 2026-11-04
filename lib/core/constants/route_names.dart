abstract class AppRoutes {
  static const String splash = '/';
  
  // Auth flow
  static const String login = '/auth/login';
  static const String mobileLogin = login; // Retained for backward compatibility
  static const String signup = '/auth/signup';
  static const String completeProfile = '/auth/complete-profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordOtp = '/auth/forgot-password-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String otpVerification = '/auth/otp';

  // Main navigation & Tabs
  static const String mainNav = '/main';
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String offers = '/offers';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Categories & Services
  static const String categories = '/categories';
  static const String serviceSearch = '/services/search';
  static const String serviceListing = '/services/listing';
  static const String serviceDetails = '/services/details';
  static const String packageSelection = '/services/packages';

  // Branches & Checkout
  static const String branchSelection = '/branches/selection';
  static const String branchDetails = '/branches/details';
  static const String addressSelection = '/checkout/addresses';
  static const String addAddress = '/checkout/addresses/add';
  static const String dateTimeSelection = '/checkout/date-time';
  static const String bookingSummary = '/checkout/summary';
  static const String payment = '/checkout/payment';
  static const String bookingConfirmation = '/checkout/confirmation';

  // Bookings & Tracking
  static const String myBookings = '/bookings/my-bookings';
  static const String bookingDetails = '/bookings/details';

  // Profile, Notifications & Reviews
  static const String notifications = '/notifications';
  static const String reviews = '/reviews';
  static const String addReview = '/reviews/add';

  static const String subscriptions = '/subscriptions';
}
