import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/bookings/data/models/booking_model.dart';
import 'package:prop_crm/features/bookings/data/models/booking_pricing_response_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_response_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_request_model.dart';
import 'package:prop_crm/features/bookings/data/models/create_booking_response_model.dart';
import 'package:prop_crm/features/bookings/data/models/reschedule_booking_response_model.dart';
import 'package:prop_crm/features/bookings/domain/repositories/booking_repository.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/booking_summary/domain/repositories/booking_summary_repository.dart';
import 'package:prop_crm/features/booking_summary/presentation/providers/booking_summary_provider.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/offers/domain/repositories/coupon_repository.dart';
import 'package:prop_crm/features/offers/model/models/coupon_model.dart';
import 'package:prop_crm/features/offers/model/models/validate_coupon_response_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

class FakeBookingSummaryRepository implements BookingSummaryRepository {
  @override
  Future<BookingSummaryModel> getBookingSummary({
    required ServiceModel service,
    required ServicePackageModel? package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  }) async {
    final basePrice = package?.price ?? service.startingPrice;
    final pricing = PricingBreakdown.calculate(
      packagePrice: basePrice,
      discount: discount,
      taxRate: taxRate,
    );
    return BookingSummaryModel(
      service: service,
      package: package,
      address: address,
      scheduledDate: date,
      timeSlot: timeSlot,
      pricing: pricing,
    );
  }
}

class FakeCouponRepository implements CouponRepository {
  ValidateCouponResponseModel? Function(String code, double subtotal)? onValidate;

  @override
  Future<List<CouponModel>> getCoupons({String? branchId}) async {
    return [
      CouponModel(
        code: 'UNIVERSE20',
        title: '20% Off all services',
        description: '20% Off all services',
        flatDiscount: 200,
        minBookingAmount: 1000,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      CouponModel(
        code: 'DIWALI20',
        title: '20% OFF on Diwali',
        description: 'Take Benefit of OFFER This Diwali',
        flatDiscount: 499,
        minBookingAmount: 2500,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      ),
    ];
  }

  @override
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    if (onValidate != null) {
      final res = onValidate!(code, subtotal);
      if (res != null) return res;
    }
    if (code.toUpperCase() == 'UNIVERSE20') {
      if (subtotal < 1000) {
        throw BadRequestException(
          message: 'Minimum order amount of ₹1000 required to apply this coupon.',
        );
      }
      return const ValidateCouponResponseModel(
        success: true,
        discountAmount: 200,
        finalSubtotal: 4300,
        message: "Coupon 'UNIVERSE20' applied successfully!",
      );
    } else if (code.toUpperCase() == 'DIWALI20') {
      if (subtotal < 2500) {
        throw BadRequestException(
          message: 'Minimum order amount of ₹2500 required to apply this coupon.',
        );
      }
      return const ValidateCouponResponseModel(
        success: true,
        discountAmount: 499,
        finalSubtotal: 4001,
        message: "Coupon 'DIWALI20' applied successfully!",
      );
    } else {
      throw NotFoundException(message: 'Invalid coupon code.');
    }
  }
}

class FakeBookingRepository implements BookingRepository {
  String? lastCalculatedCouponCode;

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
    lastCalculatedCouponCode = couponCode;
    const subtotal = 4500.0;
    if (couponCode == 'UNIVERSE20') {
      return const BookingPricingResponseModel(
        items: [],
        subtotal: subtotal,
        discount: 200,
        couponDiscount: 200,
        tax: 0,
        total: 4300,
        totalDurationMinutes: 90,
      );
    } else if (couponCode == 'DIWALI20') {
      return const BookingPricingResponseModel(
        items: [],
        subtotal: subtotal,
        discount: 499,
        couponDiscount: 499,
        tax: 0,
        total: 4001,
        totalDurationMinutes: 90,
      );
    }

    return const BookingPricingResponseModel(
      items: [],
      subtotal: subtotal,
      discount: 0,
      couponDiscount: 0,
      tax: 0,
      total: subtotal,
      totalDurationMinutes: 90,
    );
  }

  @override
  Future<CancelBookingResponseModel> cancelBookingAppointment({
    required String bookingId,
    String? reason,
  }) => throw UnimplementedError();

  @override
  Future<BookingModel> cancelBooking({
    CancelBookingRequestModel? request,
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) => throw UnimplementedError();

  @override
  Future<CreateBookingResponseModel> createBooking({
    required CreateBookingRequestModel request,
    BookingSummaryModel? summary,
    PaymentMethodModel? paymentMethod,
  }) => throw UnimplementedError();

  @override
  Future<BookingModel> getBookingById(String bookingId) =>
      throw UnimplementedError();

  @override
  Future<List<BookingModel>> getBookings({String? status}) =>
      throw UnimplementedError();

  @override
  Future<RescheduleBookingResponseModel> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
    String? reason,
  }) => throw UnimplementedError();

  @override
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
}

void main() {
  group('Coupon Validation & Discount Calculation Flow', () {
    late FakeBookingSummaryRepository summaryRepo;
    late FakeCouponRepository couponRepo;
    late FakeBookingRepository bookingRepo;
    late BookingSummaryProvider provider;

    final service = ServiceModel(
      id: '6ad9a5c38aa2e82ac2cb6cc3',
      name: 'Organic Anti-Aging Gold Facial',
      categoryId: 'cat_1',
      description: 'Facial',
      duration: '90 mins',
      startingPrice: 4500,
    );

    final branch = BranchModel(
      id: '6ae5c8633a9d7483bb75e53f',
      name: 'Raja Rao Center',
      code: 'RRC-01',
      city: 'Jaipur',
      address: 'Jaipur Central',
      phone: '9876543210',
    );

    final scheduledDate = ServiceDateModel(
      date: DateTime(2026, 11, 15),
      isAvailable: true,
    );

    const timeSlot = TimeSlotModel(
      id: '14:30',
      startTime: '14:30',
      endTime: '16:00',
      isAvailable: true,
    );

    const address = AddressModel(
      id: 'addr_1',
      userId: 'user_1',
      label: 'Home',
      houseNumber: '12',
      addressLine: 'MG Road',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302001',
    );

    setUp(() async {
      summaryRepo = FakeBookingSummaryRepository();
      couponRepo = FakeCouponRepository();
      bookingRepo = FakeBookingRepository();

      provider = BookingSummaryProvider(
        repository: summaryRepo,
        bookingRepository: bookingRepo,
        couponRepository: couponRepo,
      );

      await provider.loadSummary(
        service: service,
        package: null,
        branch: branch,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );
    });

    test('1. Valid and eligible coupon recalculates pricing from backend', () async {
      expect(provider.summary?.pricing.packagePrice, equals(4500.0));
      expect(provider.summary?.pricing.discount, equals(0.0));
      expect(provider.summary?.pricing.totalAmount, equals(4500.0));
      expect(provider.appliedCoupon, isNull);

      final success = await provider.applyCouponCode('UNIVERSE20');

      expect(success, isTrue);
      expect(provider.couponError, isNull);
      expect(provider.appliedCoupon?.code, equals('UNIVERSE20'));
      expect(provider.summary?.pricing.discount, equals(200.0));
      expect(provider.summary?.pricing.totalAmount, equals(4300.0));
      expect(bookingRepo.lastCalculatedCouponCode, equals('UNIVERSE20'));
    });

    test('2. Case-insensitivity and whitespace trimming work as expected', () async {
      final success = await provider.applyCouponCode('   universe20   ');

      expect(success, isTrue);
      expect(provider.appliedCoupon?.code, equals('UNIVERSE20'));
      expect(provider.summary?.pricing.totalAmount, equals(4300.0));
    });

    test('3. Invalid coupon code surfaces backend error and preserves pricing', () async {
      final success = await provider.applyCouponCode('INVALID999');

      expect(success, isFalse);
      expect(provider.couponError, equals('Invalid coupon code.'));
      expect(provider.appliedCoupon, isNull);
      expect(provider.summary?.pricing.discount, equals(0.0));
      expect(provider.summary?.pricing.totalAmount, equals(4500.0));
    });

    test('4. Coupon below minimum booking amount surfaces backend error', () async {
      final lowService = ServiceModel(
        id: '6ace182d092ec489511e74d4',
        name: 'Signature Haircut',
        categoryId: 'cat_hair',
        description: 'Haircut',
        duration: '45 mins',
        startingPrice: 1800,
      );

      await provider.loadSummary(
        service: lowService,
        package: null,
        branch: branch,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );

      final success = await provider.applyCouponCode('DIWALI20');

      expect(success, isFalse);
      expect(
        provider.couponError,
        equals('Minimum order amount of ₹2500 required to apply this coupon.'),
      );
      expect(provider.appliedCoupon, isNull);
      expect(provider.summary?.pricing.totalAmount, equals(1800.0));
    });

    test('5. Removing an applied coupon restores un-discounted backend pricing', () async {
      await provider.applyCouponCode('UNIVERSE20');
      expect(provider.summary?.pricing.totalAmount, equals(4300.0));
      expect(provider.appliedCoupon?.code, equals('UNIVERSE20'));

      await provider.removeCoupon();

      expect(provider.appliedCoupon, isNull);
      expect(provider.couponError, isNull);
      expect(provider.summary?.pricing.discount, equals(0.0));
      expect(provider.summary?.pricing.totalAmount, equals(4500.0));
      expect(bookingRepo.lastCalculatedCouponCode, isNull);
    });

    test('6. CouponModel parses backend JSON correctly', () {
      final couponJson = {
        '_id': '6af6df464e500d70979b2269',
        'code': 'UNIVERSE20',
        'title': '20% Off all services',
        'description': '20% Off all services',
        'discountType': 'percentage',
        'discountValue': 200,
        'minOrderAmount': 1000,
        'maxDiscount': 200,
        'validUntil': '2026-12-31T00:00:00.000Z',
        'allBranchesApplicable': true,
      };

      final coupon = CouponModel.fromJson(couponJson);
      expect(coupon.code, equals('UNIVERSE20'));
      expect(coupon.title, equals('20% Off all services'));
      expect(coupon.minBookingAmount, equals(1000.0));
      expect(coupon.maxDiscount, equals(200.0));
      expect(coupon.isActive, isTrue);
    });

    test('7. BookingPricingResponseModel parses backend calculate-pricing JSON', () {
      final pricingJson = {
        'success': true,
        'data': {
          'subtotal': 4500,
          'discount': 200,
          'couponDiscount': 200,
          'pointsDiscount': 0,
          'tax': 0,
          'total': 4300,
          'totalDurationMinutes': 90,
          'items': [
            {
              'serviceId': '6ad9a5c38aa2e82ac2cb6cc3',
              'serviceName': 'Organic Anti-Aging Gold Facial',
              'productId': null,
              'productBrand': 'Standard Salon In-House',
              'productPriceModifier': 0,
              'stylistId': '6ad9ad338aa2e82ac2cb6cd1',
              'stylistName': 'Any Available Specialist',
              'itemPrice': 4500,
              'itemDuration': 90,
            }
          ],
        }
      };

      final pricing = BookingPricingResponseModel.fromJson(pricingJson);
      expect(pricing.subtotal, equals(4500.0));
      expect(pricing.couponDiscount, equals(200.0));
      expect(pricing.discount, equals(200.0));
      expect(pricing.tax, equals(0.0));
      expect(pricing.total, equals(4300.0));
      expect(pricing.finalAmount, equals(4300.0));
      expect(pricing.totalDurationMinutes, equals(90));
      expect(pricing.items.length, equals(1));
      expect(pricing.items.first.serviceName, equals('Organic Anti-Aging Gold Facial'));
    });
  });
}
