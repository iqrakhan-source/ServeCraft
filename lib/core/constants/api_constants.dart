
abstract class ApiConstants {
  // Base URL (overridden dynamically by AppConfig)
  static const String defaultBaseUrl = 'http://157.20.51.180:5004/';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String applicationJson = 'application/json';
  static const String clientTypeHeader = 'X-Client-Type';
  static const String clientConsumer = 'consumer';
  static const String clientVersionHeader = 'X-Client-Version';

  // ============================================================
  // CUSTOMER AUTH
  // ============================================================

  static const String registerCustomer =
      '/api/customer/auth/register';

  static const String register = registerCustomer;

  static const String login =
      '/api/customer/auth/login';

  static const String refreshToken =
      '/api/customer/auth/refresh-token';

  static const String logout =
      '/api/customer/auth/logout';

  static const String forgotPassword =
      '/api/customer/auth/password/forgot';

  static const String verifyPasswordCode =
      '/api/customer/auth/password/verify-code';

  static const String resetPassword =
      '/api/customer/auth/password/reset';

  // OTP Fallbacks
  static const String sendOtp =
      '/api/v1/customer/auth/send-otp';

  static const String verifyOtp =
      '/api/v1/customer/auth/verify-otp';

  static const String signupSendOtp =
      '/signup/send-otp';

  // ============================================================
  // CUSTOMER PROFILE
  // ============================================================

  static const String profile =
      '/api/customer/profile';

  static const String updateProfile =
      '/api/customer/profile/complete';

  static const String completeProfile =
      '/api/customer/profile';

  static const String profilePhoto =
      '/api/customer/profile/photo';

  static const String fcmToken =
      '/api/customer/profile/fcm-token';

  static const String clinicalPreferences =
      '/api/customer/profile/clinical-preferences';

  static const String updateClinicalPreferences =
      clinicalPreferences;

  // ============================================================
  // BRANCHES & AVAILABILITY
  // ============================================================

  static const String branches =
      '/api/customer/branches';

  static String branchTiming(String id) =>
      '/api/customer/branches/$id/timing';

  static String availableChairs(String branchId) =>
      '/api/customer/branches/$branchId/available-chairs';

  static String availableSlots(String branchId) =>
      '/api/customer/branches/$branchId/available-slots';

  static const String stylists =
      '/api/customer/bookings/stylists';

  // ============================================================
  // ADDRESSES
  // ============================================================

  static const String addresses = '/addresses';

  static String addressById(String id) =>
      '/addresses/$id';

  static String setDefaultAddress(String id) =>
      '/addresses/$id/default';

  // ============================================================
  // HOME & DISCOVERY
  // ============================================================

  static const String home = '/home';

  static const String dashboard =
      '/api/customer/dashboard';

  // ============================================================
  // CATEGORIES & SERVICES
  // ============================================================

  static const String categories =
      '/api/customer/categories';

  static String categoryById(String id) =>
      '/categories/$id';

  static const String services =
      '/api/customer/services';

  static String serviceById(String id) =>
      '/services/$id';

  static String packagesByServiceId(String serviceId) =>
      '/services/$serviceId/packages';

  static String serviceAvailability(String serviceId) =>
      '/services/$serviceId/availability';

  static String serviceSlotsByDate(
      String serviceId,
      String date,
      ) =>
      '/services/$serviceId/availability?date=$date';

  // ============================================================
  // PRODUCTS FOR SERVICE
  // Verified: GET /api/customer/bookings/products-for-service/:serviceId
  // ============================================================

  static const String productsForService =
      '/api/customer/bookings/products-for-service';

  static String productsForServiceById(String serviceId) =>
      '/api/customer/bookings/products-for-service/$serviceId';

  // ============================================================
  // BOOKING PRICING
  // Verified: POST /api/customer/bookings/calculate-pricing
  // ============================================================

  static const String calculatePricing =
      '/api/customer/bookings/calculate-pricing';

  static const String calculateCombo =
      '/api/customer/calculate-combo';

  // ============================================================
  // CHAIR HOLD & BOOKINGS
  // ============================================================

  // Verified: POST /api/customer/bookings/hold-chair
  static const String holdChair =
      '/api/customer/bookings/hold-chair';

  // Verified: POST /api/customer/bookings
  static const String createBooking =
      '/api/customer/bookings';

  // Verified: GET /api/customer/bookings
  static const String appointments =
      '/api/customer/bookings';

  static const String bookings = appointments;

  // Booking details
  static String appointmentById(String id) =>
      '/api/customer/bookings/$id';

  static String bookingById(String id) =>
      appointmentById(id);

  static String bookingDetails(String id) =>
      appointmentById(id);

  // Invoice (not verified in supplied screenshots)
  static String bookingInvoice(String bookingId) =>
      '/api/customer/bookings/$bookingId/invoice';

  // Verified: GET /api/customer/bookings/:id/cancel-policy
  static String bookingCancelPolicy(String id) =>
      '/api/customer/bookings/$id/cancel-policy';

  // Verified: POST /api/customer/bookings/:id/cancel
  static String cancelAppointment(String id) =>
      '/api/customer/bookings/$id/cancel';

  static String cancelBooking(String id) =>
      cancelAppointment(id);

  // Reschedule (not verified in supplied screenshots)
  static String rescheduleAppointment(String id) =>
      '/api/customer/bookings/$id/reschedule';

  static String rescheduleBooking(String id) =>
      rescheduleAppointment(id);

  // Review (not verified in supplied screenshots)
  static String reviewBooking(String id) =>
      '/api/customer/bookings/$id/review';

  // ============================================================
  // PAYMENTS
  // ============================================================

  static const String paymentMethods =
      '/api/customer/payments/methods';

  static const String createPaymentOrder =
      '/api/customer/payments/create-order';

  static const String verifyPayment =
      '/api/customer/payments/verify';

  static const String processPayment =
      '/payments/process';

  static const String createPayment =
      createPaymentOrder;

  static String paymentById(String id) =>
      '/payments/$id';

  // ============================================================
  // REVIEWS
  // ============================================================

  static const String reviews = '/reviews';

  static String reviewsByServiceId(String serviceId) =>
      '/services/$serviceId/reviews';

  // ============================================================
  // COUPONS
  // ============================================================

  static const String customerCoupons =
      '/api/customer/coupons';

  static const String validateCoupon =
      '/api/customer/coupons/validate';

  static const String applyCustomerCoupon =
      validateCoupon;

  // ============================================================
  // MEMBERSHIPS
  // ============================================================

  static const String membershipPlans =
      '/api/customer/memberships/plans';

  static const String myMembership =
      '/api/customer/memberships/my-membership';

  static const String subscribeMembership =
      '/api/customer/memberships/subscribe';

  static const String subscriptionPlans =
      membershipPlans;

  // ============================================================
  // WAITLIST
  // ============================================================

  static const String waitlist =
      '/api/customer/waitlist';

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  static const String notifications =
      '/api/customer/notifications';

  static String readNotification(String id) =>
      '/api/customer/notifications/$id/read';
}
