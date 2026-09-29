import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/cancel_booking_request_model.dart';
import '../../data/models/create_booking_request_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings();

  Future<BookingModel> getBookingById(String bookingId);

  Future<BookingModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  });

  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  });
}
