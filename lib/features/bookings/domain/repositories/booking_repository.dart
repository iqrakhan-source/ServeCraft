import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/booking_pricing_response_model.dart';
import '../../data/models/cancel_booking_request_model.dart';
import '../../data/models/cancel_booking_response_model.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../data/models/create_booking_response_model.dart';
import '../../data/models/reschedule_booking_response_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings({String? status});

  Future<BookingModel> getBookingById(String bookingId);

  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  });

  Future<BookingPricingResponseModel> calculatePricing({
    required String branchId,
    String? date,
    String? timeSlot,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    bool? useLoyaltyPoints,
    int? pointsToRedeem,
  });

  Future<CancelBookingResponseModel> cancelBookingAppointment({
    required String bookingId,
    String? reason,
  });

  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  });

  Future<RescheduleBookingResponseModel> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
    String? reason,
  });

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  });
}
