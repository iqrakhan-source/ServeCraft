abstract class ApiConstants {
  // Base URL (overridden dynamically by AppConfig)
  static const String liveBaseUrl = 'http://157.20.51.180:5004';
  static const String localBaseUrl = 'http://localhost:5000';
  static const String defaultBaseUrl = liveBaseUrl;

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
  static const String multipartFormData = 'multipart/form-data';
  static const String clientTypeHeader = 'X-Client-Type';
  static const String clientConsumer = 'consumer';
  static const String clientVersionHeader = 'X-Client-Version';

  // ============================================================
  // 1. AUTHENTICATION & ONBOARDING APIS
  // ============================================================

  /// POST /api/customer/auth/register
  static const String registerCustomer = '/api/customer/auth/register';
  static const String register = registerCustomer;

  /// POST /api/customer/auth/login
  static const String login = '/api/customer/auth/login';

  /// POST /api/customer/auth/refresh-token
  static const String refreshToken = '/api/customer/auth/refresh-token';

  /// POST /api/customer/auth/forgot-password
  static const String forgotPassword = '/api/customer/auth/forgot-password';

  /// POST /api/customer/auth/reset-password
  static const String resetPassword = '/api/customer/auth/reset-password';

  /// PUT /api/customer/auth/change-password
  static const String changePassword = '/api/customer/auth/change-password';

  /// POST /api/customer/auth/logout
  static const String logout = '/api/customer/auth/logout';

  // Legacy & OTP Fallbacks (Contract Section 11)
  static const String legacyLogin = '/api/v1/customer/auth/login';
  static const String sendOtp = '/api/v1/customer/auth/send-otp';
  static const String verifyOtp = '/api/v1/customer/auth/verify-otp';
  static const String signupSendOtp = '/signup/send-otp';
  static const String verifyPasswordCode =
      '/api/customer/auth/password/verify-code';

  // ============================================================
  // 2. CUSTOMER PROFILE & AESTHETIC PREFERENCES
  // ============================================================

  /// GET /api/customer/profile
  /// PATCH/PUT /api/customer/profile
  static const String profile = '/api/customer/profile';
  static const String updateProfile = '/api/customer/profile';
  static const String completeProfile = '/api/customer/profile';

  /// POST /api/customer/profile/photo
  static const String profilePhoto = '/api/customer/profile/photo';

  /// POST /api/customer/profile/fcm-token
  static const String fcmToken = '/api/customer/profile/fcm-token';

  /// PATCH /api/customer/profile/preferences
  static const String preferences = '/api/customer/profile/preferences';
  static const String clinicalPreferences = '/api/customer/profile/preferences';
  static const String updateClinicalPreferences = preferences;

  // Legacy profile endpoints
  static const String legacyProfile = '/api/v1/customer/profile';
  static const String legacyClinicalPreferences =
      '/api/v1/customer/profile/clinical-preferences';

  // ============================================================
  // 3. BRANCH DISCOVERY & GEOLOCATION (GPS)
  // ============================================================

  /// GET /api/customer/branches (query: lat, lng, radiusKm, city, search)
  static const String branches = '/api/customer/branches';

  /// GET /api/customer/branches/:id
  static String branchById(String id) => '/api/customer/branches/$id';

  /// GET /api/customer/branches/:id/chair-availability (query: date, timeSlot)
  static String branchChairAvailability(String id) =>
      '/api/customer/branches/$id/chair-availability';

  // Backward compatibility aliases
  static String branchTiming(String id) => '/api/customer/branches/$id/timing';
  static String availableChairs(String branchId) =>
      branchChairAvailability(branchId);

  /// GET /api/customer/branches/:id/available-slots (query: date, serviceId, duration)
  static String availableSlots(String branchId) =>
      '/api/customer/branches/$branchId/available-slots';
  static const String stylists = '/api/customer/bookings/stylists';

  // ============================================================
  // 4. SERVICES & CATEGORIES CATALOG
  // ============================================================

  /// GET /api/customer/categories
  static const String categories = '/api/customer/categories';

  static String categoryById(String id) => '/api/customer/categories/$id';

  /// GET /api/customer/services (query: branch, category, gender)
  static const String services = '/api/customer/services';

  static String serviceById(String id) => '/api/customer/services/$id';

  static String packagesByServiceId(String serviceId) =>
      '/api/customer/services/$serviceId/packages';

  static String serviceAvailability(String serviceId) =>
      '/api/customer/services/$serviceId/availability';

  static String serviceSlotsByDate(String serviceId, String date) =>
      '/api/customer/services/$serviceId/availability?date=$date';

  static const String productsForService =
      '/api/customer/bookings/products-for-service';

  static String productsForServiceById(String serviceId) =>
      '/api/customer/bookings/products-for-service/$serviceId';

  // ============================================================
  // 5. APPOINTMENT BOOKING & BILLING (ZERO GST)
  // ============================================================

  /// POST /api/customer/bookings/calculate-pricing (Live Server)
  /// POST /api/customer/bookings/calculate (Contract Alternate)
  static const String calculatePricing =
      '/api/customer/bookings/calculate-pricing';
  static const String calculatePricingAlt = '/api/customer/bookings/calculate';
  static const String calculateBooking = calculatePricing;

  /// POST /api/customer/bookings (Live Server)
  /// POST /api/customer/bookings/create (Contract Alternate)
  static const String createBooking = '/api/customer/bookings';
  static const String createBookingAlt = '/api/customer/bookings';

  /// GET /api/customer/bookings (Live Server - avoid Express /bookings/:id "my" ObjectId cast collision)
  /// GET /api/customer/bookings/my (Contract Alternate)
  static const String myBookings = '/api/customer/bookings';
  static const String myBookingsAlt = '/api/customer/bookings/my';
  static const String appointments = myBookings;
  static const String bookings = myBookings;

  /// GET /api/customer/bookings/:id
  static String appointmentById(String id) => '/api/customer/bookings/$id';
  static String bookingById(String id) => appointmentById(id);
  static String bookingDetails(String id) => appointmentById(id);

  /// POST /api/customer/bookings/:id/cancel
  static String cancelAppointment(String id) =>
      '/api/customer/bookings/$id/cancel';
  static String cancelBooking(String id) => cancelAppointment(id);

  /// POST /api/customer/bookings/:id/reschedule
  static String rescheduleAppointment(String id) =>
      '/api/customer/bookings/$id/reschedule';
  static String rescheduleBooking(String id) => rescheduleAppointment(id);

  /// POST /api/customer/bookings/:id/review OR POST /api/customer/reviews/:id
  static String reviewBooking(String id) => '/api/customer/bookings/$id/review';
  static String reviewAppointment(String id) => reviewBooking(id);
  static String submitReview(String id) => '/api/customer/reviews/$id';

  // Legacy V1 endpoints
  static const String legacyCreateBooking = '/api/v1/customer/booking/create';
  static const String legacyCancelBooking = '/api/v1/customer/booking/cancel';
  static const String legacyAppointments = '/api/v1/customer/appointments';

  // Additional booking constants
  static const String holdChair = '/api/customer/bookings/hold-chair';
  static const String calculateCombo = '/api/customer/calculate-combo';
  static String bookingInvoice(String bookingId) =>
      '/api/customer/bookings/$bookingId/invoice';
  static String bookingCancelPolicy(String id) =>
      '/api/customer/bookings/$id/cancel-policy';

  // ============================================================
  // 6. LOYALTY POINTS & REWARDS PASSBOOK
  // ============================================================

  /// GET /api/customer/loyalty/wallet
  static const String loyaltyWallet = '/api/customer/loyalty/wallet';

  /// GET /api/customer/loyalty/history (query: page=1, limit=20)
  static const String loyaltyHistory = '/api/customer/loyalty/history';

  // ============================================================
  // 7. COUPONS & PROMOTIONAL OFFERS
  // ============================================================

  /// GET /api/customer/coupons (query: branchId)
  static const String customerCoupons = '/api/customer/coupons';

  /// POST /api/customer/coupons/validate
  static const String validateCoupon = '/api/customer/coupons/validate';
  static const String applyCustomerCoupon = validateCoupon;

  // ============================================================
  // 8. MEMBERSHIPS & SUBSCRIPTIONS
  // ============================================================

  /// GET /api/customer/subscriptions/plans
  static const String subscriptionPlans = '/api/customer/subscriptions/plans';
  static const String membershipPlans = subscriptionPlans;

  /// POST /api/customer/subscriptions/purchase
  static const String purchaseSubscription =
      '/api/customer/subscriptions/purchase';
  static const String subscribeMembership = purchaseSubscription;

  /// GET /api/customer/subscriptions/invoices
  static const String subscriptionInvoices =
      '/api/customer/subscriptions/invoices';

  static const String myMembership = '/api/customer/memberships/my-membership';

  // ============================================================
  // 9. WAITLIST MANAGEMENT
  // ============================================================

  /// POST /api/customer/waitlist/join
  static const String joinWaitlist = '/api/customer/waitlist/join';

  /// GET /api/customer/waitlist/my
  static const String myWaitlist = '/api/customer/waitlist';
  static const String waitlist = myWaitlist;

  // ============================================================
  // 10. PUSH NOTIFICATIONS
  // ============================================================

  /// GET /api/customer/notifications
  static const String notifications = '/api/customer/notifications';

  /// PATCH /api/customer/notifications/:id/read
  static String readNotification(String id) =>
      '/api/customer/notifications/$id/read';

  // ============================================================
  // ADDRESSES & PAYMENTS (SUPPORTING SERVICES)
  // ============================================================

  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String setDefaultAddress(String id) => '/addresses/$id/default';

  static const String home = '/home';
  static const String dashboard = '/api/customer/dashboard';

  static const String paymentMethods = '/api/customer/payments/methods';
  static const String createPaymentOrder =
      '/api/customer/payments/create-order';
  static const String verifyPayment = '/api/customer/payments/verify';
  static const String processPayment = '/payments/process';
  static const String createPayment = createPaymentOrder;
  static String paymentById(String id) => '/payments/$id';

  static const String reviews = '/reviews';
  static String reviewsByServiceId(String serviceId) =>
      '/services/$serviceId/reviews';
}
