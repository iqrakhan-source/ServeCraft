import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
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
        bookingReference: 'LX-2026-0042',
        status: BookingStatus.confirmed,
        service: const ServiceModel(
          id: 'srv_exec_haircut',
          categoryId: 'cat_hair_styling',
          name: 'Executive Haircut & Styling',
          description: 'Precision scissor or clipper haircut customized to your face profile with scalp therapy wash.',
          startingPrice: 499.0,
          duration: '45 mins',
          rating: 4.9,
          image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
        ),
        package: const ServicePackageModel(
          id: 'pkg_exec_master',
          serviceId: 'srv_exec_haircut',
          name: 'Master Cut & Scalp Therapy',
          description: 'Includes consultation, hair wash, scalp massage, master styling',
          price: 699.0,
          duration: '50 mins',
          features: ['Hair Consultation', 'Scalp Massage', 'Precision Cut', 'Matte Finish'],
        ),
        branch: const BranchModel(
          id: 'br_downtown',
          name: 'Downtown Luxury Lounge',
          address: '102 Park Avenue, 2nd Floor, Central District, Bengaluru',
          phone: '+91 98765 43210',
          rating: 4.9,
          reviewCount: 428,
          imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
          workingDays: [1, 2, 3, 4, 5, 6, 7],
          openingTime: '09:00',
          closingTime: '21:00',
          isActive: true,
          amenities: ['Valet Parking', 'Free Wi-Fi', 'Complimentary Beverage', 'Private VIP Suite', 'AC'],
        ),
        address: const AddressModel(
          id: 'addr_branch_01',
          userId: 'user_current',
          label: 'Downtown Branch',
          houseNumber: '102 Park Ave',
          addressLine: 'Central District',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560001',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime.now().add(const Duration(days: 1)),
          isAvailable: true,
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_11am',
          startTime: '11:00 AM',
          endTime: '12:00 PM',
          isAvailable: true,
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pm_salon',
          title: 'Pay at Salon',
          subtitle: 'Pay at front desk reception after your appointment (Cash, Card, or UPI)',
          type: PaymentMethodType.cod,
          isAvailable: true,
        ),
        pricing: PricingBreakdown.calculate(
          packagePrice: 699.0,
          discount: 100.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    );

    // Seed 2: Completed
    _bookings.add(
      BookingModel(
        id: 'bk_seed_002',
        bookingReference: 'LX-2026-0038',
        status: BookingStatus.completed,
        service: const ServiceModel(
          id: 'srv_hydra_facial',
          categoryId: 'cat_facial',
          name: 'Hydra Medi-Facial & Glow',
          description: '6-step medical grade hydra-dermabrasion with peptide infusions.',
          startingPrice: 1799.0,
          duration: '60 mins',
          rating: 4.9,
          image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600',
        ),
        package: const ServicePackageModel(
          id: 'pkg_hydra_signature',
          serviceId: 'srv_hydra_facial',
          name: 'Signature 6-Step Hydra Glow',
          description: 'Deep pore vacuum, hyaluronic infusion, gold mask & LED light therapy',
          price: 1799.0,
          duration: '60 mins',
          features: ['Deep Pore Extraction', 'Hyaluronic Infusion', 'Cryo Toning', 'LED Therapy'],
        ),
        branch: const BranchModel(
          id: 'br_uptown',
          name: 'Uptown Style Studio',
          address: '45 Lavelle Road, Near UB City, Bengaluru',
          phone: '+91 98765 43211',
          rating: 4.8,
          reviewCount: 310,
          imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
          workingDays: [1, 2, 3, 4, 5, 6],
          openingTime: '10:00',
          closingTime: '20:30',
          isActive: true,
          amenities: ['Free Wi-Fi', 'Express Chairs', 'Beverages', 'AC'],
        ),
        address: const AddressModel(
          id: 'addr_branch_02',
          userId: 'user_current',
          label: 'Uptown Branch',
          houseNumber: '45 Lavelle Rd',
          addressLine: 'UB City Area',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560001',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime.now().subtract(const Duration(days: 4)),
          isAvailable: true,
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_02pm',
          startTime: '02:00 PM',
          endTime: '03:00 PM',
          isAvailable: true,
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pm_online',
          title: 'Online Payment',
          subtitle: 'Paid via UPI (Google Pay)',
          type: PaymentMethodType.upi,
          isAvailable: true,
        ),
        pricing: PricingBreakdown.calculate(
          packagePrice: 1799.0,
          discount: 200.0,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    );

    // Seed 3: Cancelled
    _bookings.add(
      BookingModel(
        id: 'bk_seed_003',
        bookingReference: 'LX-2026-0021',
        status: BookingStatus.cancelled,
        service: const ServiceModel(
          id: 'srv_moroccan_spa',
          categoryId: 'cat_spa',
          name: 'Moroccan Argan Hair Spa',
          description: 'Intense micro-mist steam bath infused with Moroccan argan oil.',
          startingPrice: 1299.0,
          duration: '60 mins',
          rating: 4.8,
          image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600',
        ),
        package: const ServicePackageModel(
          id: 'pkg_spa_deep',
          serviceId: 'srv_moroccan_spa',
          name: 'Deep Nourish Hair Spa',
          description: 'Deep mask, scalp massage and ozone steaming',
          price: 1299.0,
          duration: '60 mins',
          features: ['Pure Argan Treatment', 'Aromatherapy Scalp Massage', 'Micro-Mist Steam'],
        ),
        branch: const BranchModel(
          id: 'br_metro',
          name: 'Metro Salon & Spa',
          address: '77 100ft Road, Indiranagar, Bengaluru',
          phone: '+91 98765 43212',
          rating: 4.7,
          reviewCount: 195,
          imageUrl: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
          workingDays: [1, 2, 3, 4, 5, 6, 7],
          openingTime: '09:30',
          closingTime: '21:30',
          isActive: true,
          amenities: ['Valet Parking', 'Spa Jacuzzi', 'Organic Products', 'AC'],
        ),
        address: const AddressModel(
          id: 'addr_branch_03',
          userId: 'user_current',
          label: 'Indiranagar Branch',
          houseNumber: '77 100ft Rd',
          addressLine: 'Indiranagar',
          city: 'Bengaluru',
          state: 'Karnataka',
          pincode: '560038',
        ),
        scheduledDate: ServiceDateModel(
          date: DateTime.now().subtract(const Duration(days: 10)),
          isAvailable: true,
        ),
        timeSlot: const TimeSlotModel(
          id: 'slot_04pm',
          startTime: '04:00 PM',
          endTime: '05:00 PM',
          isAvailable: true,
        ),
        paymentMethod: const PaymentMethodModel(
          id: 'pm_salon',
          title: 'Pay at Salon',
          subtitle: 'Pay at front desk reception',
          type: PaymentMethodType.cod,
          isAvailable: true,
        ),
        pricing: PricingBreakdown.calculate(
          packagePrice: 1299.0,
          discount: 0.0,
        ),
        cancellationReason: 'Change of schedule',
        cancellationNote: 'Had an unexpected meeting at work',
        cancelledAt: DateTime.now().subtract(const Duration(days: 11)),
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
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
