import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/bookings/data/models/booking_pricing_response_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';
import '../models/cancel_booking_request_model.dart';
import '../models/create_booking_request_model.dart';
import '../models/create_booking_response_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BookingModel>> getBookings() {
    return remoteDataSource.getBookings();
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
    required List<Map<String, dynamic>> items,
    String? couponCode,
  }) {
    return remoteDataSource.calculatePricing(
      branchId: branchId,
      items: items,
      couponCode: couponCode,
    );
  }

}