abstract class ApiConstants {
  // Base URLs (overridden dynamically by AppConfig)
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

  // Endpoints
  // Customer Auth
  static const String registerCustomer = '/api/customer/auth/register';
  static const String forgotPassword =
      '/api/customer/auth/forgot-password';

  static const String resetPassword =
      '/api/customer/auth/reset-password';


  static const String register = registerCustomer;
  static const String login = '/api/customer/auth/login';
  static const String sendOtp = '/api/v1/customer/auth/send-otp';
  static const String verifyOtp = '/api/v1/customer/auth/verify-otp';
  static const String signupSendOtp = '/signup/send-otp';
  static const String completeProfile = '/api/v1/customer/profile';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/api/customer/auth/logout';

  // Customer Profile
  static const String profile = '/api/v1/customer/profile';
  static const String updateProfile = '/api/v1/customer/profile';
  static const String clinicalPreferences =
      '/api/v1/customer/profile/clinical-preferences';
  static const String updateClinicalPreferences = clinicalPreferences;

  // Branches
  static const String branches = '/api/v1/customer/branches';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String setDefaultAddress(String id) => '/addresses/$id/default';

  // Home & Discovery
  static const String home = '/home';

  // Categories & Services
  static const String categories = '/api/v1/customer/categories';
  static String categoryById(String id) => '/categories/$id';
  static const String services = '/api/v1/customer/services';
  static String serviceById(String id) => '/services/$id';
  static String packagesByServiceId(String serviceId) => '/services/$serviceId/packages';
  static String serviceAvailability(String serviceId) => '/services/$serviceId/availability';
  static String serviceSlotsByDate(String serviceId, String date) =>
      '/services/$serviceId/availability?date=$date';


  // Products
  static const String productsForService =
      '/api/v1/customer/products-for-service';
  static String productsForServiceById(String serviceId) =>
      '/api/v1/customer/products-for-service/$serviceId';

  // Pricing & Combo Calculations
  static const String calculatePricing = '/api/v1/customer/calculate-pricing';
  static const String calculateCombo = '/api/v1/customer/calculate-combo';

  // Booking & Slots
  static const String bookingSlots = '/api/v1/customer/booking/slots';
  static const String createBooking = '/api/v1/customer/booking/create';

  // Appointments (Customer Appointments)
  static const String appointments = '/api/v1/customer/appointments';
  static String appointmentById(String id) =>
      '/api/v1/customer/appointments/$id';
  static String cancelAppointment(String id) =>
      '/api/v1/customer/appointments/$id/cancel';
  static String rescheduleAppointment(String id) =>
      '/api/v1/customer/appointments/$id/reschedule';

  // Backwards-compatible aliases for Bookings
  static const String bookings = appointments;
  static String bookingById(String id) => appointmentById(id);
  static String bookingDetails(String id) => appointmentById(id);
  static String cancelBooking(String id) => cancelAppointment(id);
  static String rescheduleBooking(String id) => rescheduleAppointment(id);
  static const String bookingSummary = '/checkout/summary';

  // Payments
  static const String paymentMethods = '/payments/methods';
  static const String processPayment = '/payments/process';
  static const String createPayment = '/payments/create';
  static String paymentById(String id) => '/payments/$id';

  // Reviews
  static const String reviews = '/reviews';
  static String reviewsByServiceId(String serviceId) => '/services/$serviceId/reviews';

  // Offers
  static const String offers = '/offers';
  static const String applyCoupon = '/offers/apply';

  // Coupons
  static const String customerCoupons = '/api/customer/coupons';
  static const String applyCustomerCoupon = '/api/customer/coupons/apply';



}


