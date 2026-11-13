import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../models/booking_model.dart';
import '../models/booking_pricing_response_model.dart';
import '../models/cancel_booking_request_model.dart';
import '../models/cancel_booking_response_model.dart';
import '../models/create_booking_request_model.dart';
import '../models/create_booking_response_model.dart';
import '../models/reschedule_booking_response_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings({String? status});
  Future<BookingModel> getBookingById(String bookingId);
  Future<BookingPricingResponseModel> calculatePricing({
    required String branchId,
    String? date,
    String? timeSlot,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    bool? useLoyaltyPoints,
    int? pointsToRedeem,
  });

  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
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

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiService;

  BookingRemoteDataSourceImpl({required this.apiService});

  List<BookingModel> _parseBookings(dynamic json) {
    dynamic bookingsJson;

    if (json is List) {
      bookingsJson = json;
    } else if (json is Map) {
      final data = json['data'];
      if (data is Map && data['bookings'] is List) {
        bookingsJson = data['bookings'];
      } else if (data is List) {
        bookingsJson = data;
      } else if (json['bookings'] is List) {
        bookingsJson = json['bookings'];
      }
    }

    if (bookingsJson is! List) {
      return <BookingModel>[];
    }

    return bookingsJson
        .whereType<Map>()
        .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<BookingModel>> getBookings({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      query['status'] = status.trim();
    }

    // Try primary live endpoint GET /api/customer/bookings first
    try {
      final response = await apiService.get<List<BookingModel>>(
        ApiConstants.myBookings,
        queryParameters: query.isNotEmpty ? query : null,
        fromJson: _parseBookings,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (_) {
      // Fallback to legacy endpoint if primary route encounters server error
      try {
        final fallbackResponse = await apiService.get<List<BookingModel>>(
          ApiConstants.legacyAppointments,
          fromJson: _parseBookings,
        );
        if (fallbackResponse.success && fallbackResponse.data != null) {
          return fallbackResponse.data!;
        }
      } catch (_) {}
    }

    return <BookingModel>[];
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await apiService.get<BookingModel>(
      ApiConstants.bookingById(bookingId),
      fromJson: (json) {
        if (json is Map) {
          final map = Map<String, dynamic>.from(json);
          final candidate =
              map['booking'] ?? map['data']?['booking'] ?? map['data'] ?? map;
          if (candidate is Map) {
            return BookingModel.fromJson(Map<String, dynamic>.from(candidate));
          }
        }
        return BookingModel.fromJson(
          json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
        );
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const NotFoundException(message: 'Booking not found');
  }

  @override
  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) async {
    // Try primary endpoint POST /api/customer/bookings
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.createBooking,
        data: request.toJson(),
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid booking creation response.');
          }
          return Map<String, dynamic>.from(json);
        },
      );

      if (response.success && response.data != null) {
        return CreateBookingResponseModel.fromJson(response.data!);
      }
    } catch (e) {
      // If primary endpoint failed, fallback to createBookingAlt (/create)
      final fallbackResponse = await apiService.post<Map<String, dynamic>>(
        ApiConstants.createBookingAlt,
        data: request.toJson(),
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid booking creation response.');
          }
          return Map<String, dynamic>.from(json);
        },
      );

      if (fallbackResponse.success && fallbackResponse.data != null) {
        return CreateBookingResponseModel.fromJson(fallbackResponse.data!);
      }

      throw UnexpectedException(
        message: fallbackResponse.message.isNotEmpty
            ? fallbackResponse.message
            : 'Failed to create booking.',
      );
    }

    throw const UnexpectedException(message: 'Failed to create booking.');
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
  }) async {
    final primaryServiceId = items.isNotEmpty
        ? (items.first['serviceId'] ?? items.first['service'])
        : null;
    final cleanCoupon = couponCode?.trim().toUpperCase();
    final requestBody = <String, dynamic>{
      'branchId': branchId,
      'branch': branchId,
      'serviceId': ?primaryServiceId,
      'service': ?primaryServiceId,
      'date': date ?? DateTime.now().toIso8601String().split('T').first,
      'timeSlot': timeSlot ?? '14:30',
      'cartItems': items,
      'items': items,
      if (cleanCoupon != null && cleanCoupon.isNotEmpty)
        'couponCode': cleanCoupon,
      'useLoyaltyPoints': ?useLoyaltyPoints,
      if (pointsToRedeem != null && pointsToRedeem > 0)
        'pointsToRedeem': pointsToRedeem,
    };

    // Try primary endpoint calculate-pricing first
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.calculatePricing,
        data: requestBody,
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid pricing response.');
          }
          return Map<String, dynamic>.from(json);
        },
      );

      if (response.success && response.data != null) {
        return BookingPricingResponseModel.fromJson(response.data!);
      }
    } catch (e) {
      // If server explicitly rejected a coupon or validation failed, surface it
      if (cleanCoupon != null && cleanCoupon.isNotEmpty && e is ApiException) {
        rethrow;
      }

      // Fallback to alternate endpoint /calculate
      try {
        final fallbackResponse = await apiService.post<Map<String, dynamic>>(
          ApiConstants.calculatePricingAlt,
          data: requestBody,
          fromJson: (json) {
            if (json is! Map) {
              throw const FormatException('Invalid pricing response.');
            }
            return Map<String, dynamic>.from(json);
          },
        );

        if (fallbackResponse.success && fallbackResponse.data != null) {
          return BookingPricingResponseModel.fromJson(fallbackResponse.data!);
        }
      } catch (fallbackError) {
        if (cleanCoupon != null &&
            cleanCoupon.isNotEmpty &&
            fallbackError is ApiException) {
          rethrow;
        }
      }
    }

    // Default fallback pricing breakdown
    double subtotal = 0;
    for (final item in items) {
      subtotal += (item['price'] as num?)?.toDouble() ?? 0;
    }
    return BookingPricingResponseModel(
      items: const [],
      subtotal: subtotal,
      discount: 0,
      tax: 0,
      total: subtotal,
      totalDurationMinutes: 45,
    );
  }

  @override
  Future<CancelBookingResponseModel> cancelBookingAppointment({
    required String bookingId,
    String? reason,
  }) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.cancelAppointment(bookingId),
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('Invalid cancellation response.');
        }
        return Map<String, dynamic>.from(json);
      },
    );

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to cancel appointment.',
      );
    }

    return CancelBookingResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    final effectiveId = request?.bookingId ?? bookingId ?? '';
    final effectiveReason = request?.reason ?? reason ?? '';

    if (effectiveId.isEmpty) {
      throw const BadRequestException(message: 'Booking ID is required.');
    }

    final cancelData = <String, dynamic>{
      'bookingId': effectiveId,
      if (effectiveReason.trim().isNotEmpty) ...{
        'reason': effectiveReason.trim(),
        'cancellationReason': effectiveReason.trim(),
      },
      if (request?.reasonNote != null && request!.reasonNote!.trim().isNotEmpty)
        'reasonNote': request.reasonNote!.trim(),
    };

    Map<String, dynamic> parseCancellationJson(dynamic json) {
      if (json is! Map) {
        throw const FormatException('Invalid cancellation response.');
      }
      return Map<String, dynamic>.from(json);
    }

    ApiResponse<Map<String, dynamic>> response;
    try {
      response = await apiService.post<Map<String, dynamic>>(
        ApiConstants.cancelAppointment(effectiveId),
        data: cancelData,
        fromJson: parseCancellationJson,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        response = await apiService.post<Map<String, dynamic>>(
          ApiConstants.legacyCancelBooking,
          data: cancelData,
          fromJson: parseCancellationJson,
        );
      } else {
        rethrow;
      }
    }

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to cancel booking.',
      );
    }

    final responseBody = response.data;
    if (responseBody != null) {
      final bookingData = responseBody['booking'] ?? responseBody['data'];
      if (bookingData is Map &&
          bookingData.isNotEmpty &&
          (bookingData['service'] != null || bookingData['services'] != null)) {
        return BookingModel.fromJson(Map<String, dynamic>.from(bookingData));
      }
    }

    // Return synthetic cancelled booking model
    return BookingModel(
      id: effectiveId,
      bookingReference: effectiveId,
      status: BookingStatus.cancelled,
      service: const ServiceModel(
        id: '',
        categoryId: '',
        name: 'Service',
        description: '',
        startingPrice: 0,
        duration: '0 mins',
      ),
      package: const ServicePackageModel(
        id: '',
        serviceId: '',
        name: 'Standard',
        description: '',
        price: 0,
        duration: '0 mins',
        features: [],
      ),
      address: const AddressModel(
        id: '',
        userId: '',
        label: '',
        houseNumber: '',
        addressLine: '',
        city: '',
        state: '',
        pincode: '',
      ),
      scheduledDate: ServiceDateModel(date: DateTime.now()),
      timeSlot: const TimeSlotModel(id: '', startTime: '', endTime: ''),
      paymentMethod: const PaymentMethodModel(
        id: '',
        title: '',
        subtitle: '',
        type: PaymentMethodType.upi,
      ),
      pricing: const PricingBreakdown(
        packagePrice: 0,
        discount: 0,
        taxRate: 0,
        taxAmount: 0,
        totalAmount: 0,
      ),
      createdAt: DateTime.now(),
      cancellationReason: effectiveReason,
      cancellationNote: request?.reasonNote ?? reasonNote,
      cancelledAt: DateTime.now(),
    );
  }

  @override
  Future<RescheduleBookingResponseModel> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
    String? reason,
  }) async {
    final path = ApiConstants.rescheduleAppointment(bookingId);
    final body = {
      'date': date,
      'timeSlot': timeSlot,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };

    Map<String, dynamic> parseJson(dynamic json) {
      if (json is! Map) {
        throw const FormatException('Invalid reschedule response.');
      }
      return Map<String, dynamic>.from(json);
    }

    ApiResponse<Map<String, dynamic>> response;
    try {
      response = await apiService.patch<Map<String, dynamic>>(
        path,
        data: body,
        fromJson: parseJson,
      );
    } catch (e) {
      try {
        response = await apiService.put<Map<String, dynamic>>(
          path,
          data: body,
          fromJson: parseJson,
        );
      } catch (_) {
        response = await apiService.post<Map<String, dynamic>>(
          path,
          data: body,
          fromJson: parseJson,
        );
      }
    }

    if (!response.success) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to reschedule appointment.',
      );
    }

    return RescheduleBookingResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.reviewAppointment(bookingId),
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    return response.success;
  }
}

class MockBookingRemoteDataSource implements BookingRemoteDataSource {
  bool shouldFail;
  final List<BookingModel> _bookings = [];

  MockBookingRemoteDataSource({this.shouldFail = false}) {
    _seedDeterministicBookings();
  }

  void _seedDeterministicBookings() {
    _bookings.add(
      BookingModel(
        id: 'bk_seed_001',
        bookingReference: 'LX-2026-0042',
        status: BookingStatus.confirmed,
        service: const ServiceModel(
          id: 'srv_exec_haircut',
          categoryId: 'cat_hair_styling',
          name: 'Executive Haircut & Styling',
          description:
              'Precision scissor or clipper haircut customized to your face profile with scalp therapy wash.',
          startingPrice: 499.0,
          duration: '45 mins',
        ),
        package: const ServicePackageModel(
          id: 'pkg_exec_std',
          serviceId: 'srv_exec_haircut',
          name: 'Classic Executive',
          description: 'Haircut + quick rinse & blowdry',
          price: 499.0,
          duration: '45 mins',
          features: ['Haircut', 'Scalp Massage', 'Blowdry'],
        ),
        address: const AddressModel(
          id: 'addr_001',
          userId: 'usr_001',
          label: 'Salon Branch',
          houseNumber: '',
          addressLine: 'MI Road, Panch Batti',
          city: 'Jaipur',
          state: 'Rajasthan',
          pincode: '302001',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime.now().add(const Duration(days: 2)),
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_1000',
          startTime: '10:00 AM',
          endTime: '11:00 AM',
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pay_upi_gpay',
          title: 'Google Pay',
          subtitle: 'UPI ID: user@okhdfcbank',
          type: PaymentMethodType.upi,
        ),
        pricing: const PricingBreakdown(
          packagePrice: 499.0,
          discount: 0.0,
          taxRate: 0.0,
          taxAmount: 0.0,
          totalAmount: 499.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    );
  }

  @override
  Future<List<BookingModel>> getBookings({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (shouldFail) {
      throw const UnexpectedException(
        message: "Couldn't load your bookings. Please try again.",
      );
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      return _bookings
          .where((b) => b.status.name.toLowerCase() == status.toLowerCase())
          .toList();
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

    final match = _bookings
        .where((b) => b.id == bookingId || b.bookingReference == bookingId)
        .firstOrNull;

    if (match != null) return match;
    throw const NotFoundException(message: 'Booking not found');
  }

  @override
  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) async {
    throw UnimplementedError('Mock booking creation is not implemented.');
  }

  @override
  Future<CancelBookingResponseModel> cancelBookingAppointment({
    required String bookingId,
    String? reason,
  }) async {
    return const CancelBookingResponseModel(
      success: true,
      message: 'Appointment cancelled successfully.',
      refundAmount: 0.0,
      pointsRestored: 0,
    );
  }

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final effectiveBookingId = request?.bookingId ?? bookingId ?? '';
    final index = _bookings.indexWhere(
      (b) =>
          b.id == effectiveBookingId ||
          b.bookingReference == effectiveBookingId,
    );
    if (index == -1) {
      throw const NotFoundException(message: 'Booking not found.');
    }
    final existingBooking = _bookings[index];
    final updatedBooking = existingBooking.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: request?.reason ?? reason ?? '',
      cancellationNote: request?.reasonNote ?? reasonNote,
      cancelledAt: DateTime.now(),
    );
    _bookings[index] = updatedBooking;
    return updatedBooking;
  }

  @override
  Future<RescheduleBookingResponseModel> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
    String? reason,
  }) async {
    return RescheduleBookingResponseModel(
      success: true,
      message: 'Appointment rescheduled successfully',
      date: date,
      timeSlot: timeSlot,
    );
  }

  @override
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    return true;
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
  }) async {
    return const BookingPricingResponseModel(
      items: [],
      subtotal: 500,
      discount: 0,
      tax: 0,
      total: 500,
      totalDurationMinutes: 45,
    );
  }
}
