import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../models/booking_model.dart';
import '../models/cancel_booking_request_model.dart';
import '../models/create_booking_request_model.dart';

abstract class BookingRemoteDataSource {
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

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiService apiService;

  BookingRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<BookingModel>> getBookings() async {
    final response = await apiService.get<List<dynamic>>(
      ApiConstants.bookings,
      fromJson: (json) => json as List<dynamic>,
    );

    if (response.data != null) {
      return response.data!
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const UnexpectedException(message: 'Failed to fetch bookings');
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await apiService.get<BookingModel>(
      ApiConstants.bookingById(bookingId),
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const NotFoundException(message: 'Booking not found');
  }

  @override
  Future<BookingModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) async {
    final response = await apiService.post<BookingModel>(
      ApiConstants.createBooking,
      data: request.toJson(),
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const UnexpectedException(message: 'Failed to create booking');
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    final effectiveRequest = request ??
        CancelBookingRequestModel(
          bookingId: bookingId ?? '',
          reason: reason ?? '',
          reasonNote: reasonNote,
        );

    final response = await apiService.post<BookingModel>(
      ApiConstants.cancelBooking(effectiveRequest.bookingId),
      data: effectiveRequest.toJson(),
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const UnexpectedException(message: 'Failed to cancel booking');
  }
}

class MockBookingRemoteDataSource implements BookingRemoteDataSource {
  int _counter = 1;
  bool shouldFail;
  final List<BookingModel> _bookings = [];

  MockBookingRemoteDataSource({this.shouldFail = false}) {
    _seedDeterministicBookings();
  }

  void _seedDeterministicBookings() {
    // Seed 1: Confirmed (Upcoming)
    _bookings.add(
      BookingModel(
        id: 'bk_seed_001',
        bookingReference: 'SC-2026-000101',
        status: BookingStatus.confirmed,
        service: const ServiceModel(
          id: 'srv_deep_cleaning',
          categoryId: 'cat_cleaning',
          name: 'Home Deep Cleaning',
          description: 'Comprehensive sanitization and scrubbing for residential spaces.',
          startingPrice: 999.0,
        ),
        package: const ServicePackageModel(
          id: 'pkg_cleaning_premium',
          serviceId: 'srv_deep_cleaning',
          name: 'Premium Deep Cleaning',
          description: 'Complete home service including balcony and wet areas',
          price: 999.0,
          duration: '2-3 hrs',
          features: ['Deep Scrubbing', 'Kitchen Degreasing', 'Balcony Wash', 'Sanitization'],
        ),
        address: const AddressModel(
          id: 'addr_seed_01',
          userId: 'user_current',
          label: 'Home',
          houseNumber: 'Flat 302',
          addressLine: 'Royal Palms, Vaishali Nagar',
          city: 'Jaipur',
          state: 'Rajasthan',
          pincode: '302021',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime(2026, 9, 28),
          isAvailable: true,
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_10am',
          startTime: '10:00 AM',
          endTime: '12:00 PM',
          isAvailable: true,
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pm_upi',
          title: 'UPI',
          subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
          type: PaymentMethodType.upi,
          isAvailable: true,
        ),
        pricing: PricingBreakdown.calculate(
          packagePrice: 999.0,
          discount: 100.0,
        ),
        createdAt: DateTime(2026, 9, 22, 10, 30),
      ),
    );

    // Seed 2: Completed
    _bookings.add(
      BookingModel(
        id: 'bk_seed_002',
        bookingReference: 'SC-2026-000099',
        status: BookingStatus.completed,
        service: const ServiceModel(
          id: 'srv_kitchen_cleaning',
          categoryId: 'cat_cleaning',
          name: 'Kitchen Deep Cleaning',
          description: 'Intensive degreasing and tile cleaning for residential kitchens.',
          startingPrice: 499.0,
        ),
        package: const ServicePackageModel(
          id: 'pkg_kitchen_standard',
          serviceId: 'srv_kitchen_cleaning',
          name: 'Standard Kitchen Clean',
          description: 'Exhaust fan, countertop, and floor cleaning',
          price: 499.0,
          duration: '1-2 hrs',
          features: ['Exhaust Degreasing', 'Tile Scrubbing', 'Countertop Sanitization'],
        ),
        address: const AddressModel(
          id: 'addr_seed_01',
          userId: 'user_current',
          label: 'Home',
          houseNumber: 'Flat 302',
          addressLine: 'Royal Palms, Vaishali Nagar',
          city: 'Jaipur',
          state: 'Rajasthan',
          pincode: '302021',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime(2026, 9, 15),
          isAvailable: true,
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_02pm',
          startTime: '02:00 PM',
          endTime: '03:30 PM',
          isAvailable: true,
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pm_card',
          title: 'Credit / Debit Card',
          subtitle: 'Visa, MasterCard, RuPay',
          type: PaymentMethodType.card,
          isAvailable: true,
        ),
        pricing: PricingBreakdown.calculate(
          packagePrice: 499.0,
          discount: 0.0,
        ),
        createdAt: DateTime(2026, 9, 14, 15, 0),
      ),
    );
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (shouldFail) {
      throw const UnexpectedException(
        message: "Couldn't load your bookings. Please try again.",
      );
    }

    return List<BookingModel>.from(_bookings);
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw const UnexpectedException(
        message: "Couldn't load booking details. Please try again.",
      );
    }

    final match = _bookings.where(
      (b) => b.id == bookingId || b.bookingReference == bookingId,
    ).firstOrNull;

    if (match != null) {
      return match;
    }

    throw const NotFoundException(message: 'Booking not found');
  }

  @override
  Future<BookingModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (shouldFail) {
      throw const UnexpectedException(
        message: "We couldn't confirm your booking. Please try again.",
      );
    }

    final reference =
        'SC-2026-${_counter.toString().padLeft(6, '0')}';
    _counter++;

    // Preserve actual selected checkout state if provided
    final ServiceModel service = summary?.service ??
        ServiceModel(
          id: request.serviceId,
          categoryId: 'cat_cleaning',
          name: 'Home Deep Cleaning',
          description: 'Standard deep clean',
          startingPrice: request.totalAmount,
        );

    final ServicePackageModel package = summary?.package ??
        ServicePackageModel(
          id: request.packageId,
          serviceId: request.serviceId,
          name: 'Premium Deep Cleaning',
          description: 'Complete home service',
          price: request.totalAmount,
          duration: '2-3 hrs',
          features: const ['Deep Cleaning', 'Sanitization'],
        );

    final AddressModel address = summary?.address ??
        AddressModel(
          id: request.addressId,
          userId: 'user_current',
          label: 'Home',
          houseNumber: 'Flat 302',
          addressLine: 'Royal Palms, Vaishali Nagar',
          city: 'Jaipur',
          state: 'Rajasthan',
          pincode: '302021',
        );

    final ServiceDateModel scheduledDate = summary?.scheduledDate ??
        ServiceDateModel(
          date: DateTime.tryParse(request.scheduledDate) ?? DateTime.now(),
          isAvailable: true,
        );

    final TimeSlotModel timeSlot = summary?.timeSlot ??
        TimeSlotModel(
          id: request.timeSlotId,
          startTime: '10:00 AM',
          endTime: '12:00 PM',
          isAvailable: true,
        );

    final PaymentMethodModel payment = paymentMethod ??
        PaymentMethodModel(
          id: request.paymentMethodId,
          title: 'UPI',
          subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
          type: PaymentMethodType.upi,
          isAvailable: true,
        );

    final PricingBreakdown pricing = summary?.pricing ??
        PricingBreakdown.calculate(
          packagePrice: request.totalAmount,
          discount: 0,
        );

    final createdBooking = BookingModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      bookingReference: reference,
      status: BookingStatus.confirmed,
      service: service,
      package: package,
      address: address,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      paymentMethod: payment,
      pricing: pricing,
      createdAt: DateTime.now(),
    );

    // Session-level in-memory persistence: insert at top
    _bookings.insert(0, createdBooking);

    return createdBooking;
  }

  void addBooking(BookingModel booking) {
    _bookings.add(booking);
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    final effectiveRequest = request ??
        CancelBookingRequestModel(
          bookingId: bookingId ?? '',
          reason: reason ?? '',
          reasonNote: reasonNote,
        );

    await Future.delayed(const Duration(milliseconds: 150));

    if (shouldFail) {
      throw const UnexpectedException(
        message: "Couldn't cancel this booking. Please try again.",
      );
    }

    final index = _bookings.indexWhere(
      (b) => b.id == effectiveRequest.bookingId || b.bookingReference == effectiveRequest.bookingId,
    );

    if (index == -1) {
      throw const NotFoundException(message: 'Booking not found');
    }

    final targetBooking = _bookings[index];

    if (!targetBooking.isCancellable) {
      throw const BadRequestException(
        message: 'This booking cannot be cancelled.',
      );
    }

    final updatedBooking = targetBooking.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: effectiveRequest.reason,
      cancellationNote: effectiveRequest.reasonNote,
      cancelledAt: DateTime.now(),
    );

    _bookings[index] = updatedBooking;
    return updatedBooking;
  }
}
