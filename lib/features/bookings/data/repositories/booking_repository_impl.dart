import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/bookings/data/models/booking_pricing_response_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';
import '../models/cancel_booking_request_model.dart';
import '../models/cancel_booking_response_model.dart';
import '../models/create_booking_request_model.dart';
import '../models/create_booking_response_model.dart';
import '../models/reschedule_booking_response_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BookingModel>> getBookings({String? status}) {
    return remoteDataSource.getBookings(status: status);
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) {
    return remoteDataSource.getBookingById(bookingId);
  }

  @override
  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) {
    return remoteDataSource.createBooking(
      request: request,
      summary: summary,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<CancelBookingResponseModel> cancelBookingAppointment({
    required String bookingId,
    String? reason,
  }) {
    return remoteDataSource.cancelBookingAppointment(
      bookingId: bookingId,
      reason: reason,
    );
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) {
    return remoteDataSource.cancelBooking(
      request: request,
      bookingId: bookingId,
      reason: reason,
      reasonNote: reasonNote,
    );
  }

  @override
  Future<BookingPricingResponseModel> calculatePricing({
    required String branchId,
    String? date,
    String? timeSlot,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    bool? useLoyaltyPoints,
    int? pointsToRedeem,
  }) {
    return remoteDataSource.calculatePricing(
      branchId: branchId,
      date: date,
      timeSlot: timeSlot,
      items: items,
      couponCode: couponCode,
      useLoyaltyPoints: useLoyaltyPoints,
      pointsToRedeem: pointsToRedeem,
    );
  }

  @override
  Future<RescheduleBookingResponseModel> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
    String? reason,
  }) {
    return remoteDataSource.rescheduleBooking(
      bookingId: bookingId,
      date: date,
      timeSlot: timeSlot,
      reason: reason,
    );
  }

  @override
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) {
    return remoteDataSource.submitReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }
}
