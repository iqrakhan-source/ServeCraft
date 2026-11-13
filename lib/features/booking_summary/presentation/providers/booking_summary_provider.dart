import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/bookings/domain/repositories/booking_repository.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/offers/domain/repositories/coupon_repository.dart';
import 'package:prop_crm/features/offers/model/models/coupon_model.dart';
import 'package:prop_crm/features/offers/model/models/validate_coupon_response_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../../../services/data/models/service_products_response.dart';
import '../../data/models/booking_summary_model.dart';
import '../../data/models/pricing_breakdown_model.dart';
import '../../domain/repositories/booking_summary_repository.dart';

class BookingSummaryProvider extends ChangeNotifier {
  final BookingSummaryRepository repository;
  final BookingRepository? bookingRepository;
  final CouponRepository? couponRepository;

  ViewState<BookingSummaryModel> _summaryState = ViewState.initial();
  double _discount = 0.0;
  double _taxRate = PricingBreakdown.defaultTaxRate;
  CouponModel? _appliedCoupon;
  String? _couponError;
  bool _isApplyingCoupon = false;

  BookingSummaryProvider({
    required this.repository,
    this.bookingRepository,
    this.couponRepository,
  });

  ViewState<BookingSummaryModel> get summaryState => _summaryState;
  BookingSummaryModel? get summary => _summaryState.data;

  bool get isLoading => _summaryState.isLoading;
  bool get hasError => _summaryState.isError;
  String? get errorMessage => _summaryState.errorMessage;
  bool get isValid => summary?.isValid ?? false;

  ServiceModel? get service => summary?.service;
  ServicePackageModel? get package => summary?.package;
  BranchModel? get branch => summary?.branch;
  AddressModel? get address => summary?.address;
  ServiceDateModel? get scheduledDate => summary?.scheduledDate;
  TimeSlotModel? get timeSlot => summary?.timeSlot;
  PricingBreakdown? get pricing => summary?.pricing;

  CouponModel? get appliedCoupon => _appliedCoupon ?? summary?.appliedCoupon;

  String? get couponError => _couponError;
  bool get isApplyingCoupon => _isApplyingCoupon;

  // Uses package price when selected, otherwise service starting price.
  double get selectedBookingPrice =>
      summary?.package?.price ?? summary?.service.startingPrice ?? 0.0;

  ConsumableProduct? _selectedProduct;

  ConsumableProduct? get selectedProduct => _selectedProduct;

  void setSelectedProduct(ConsumableProduct? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Loads or calculates a full booking summary with all selections.
  Future<void> loadSummary({
    required ServiceModel service,
    required ServicePackageModel? package,
    AddressModel? address,
    BranchModel? branch,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double? discount,
    double? taxRate,
    String? stylistId,
    String? stylistName,
    String? chairNumber,
    String? productId,
  }) async {
    _discount = discount ?? _discount;
    _taxRate = taxRate ?? _taxRate;

    _summaryState = ViewState.loading();
    notifyListeners();

    try {
      final safeAddress =
          address ??
          const AddressModel(
            id: 'branch_loc',
            userId: 'salon',
            label: 'Salon Branch',
            houseNumber: '',
            addressLine: 'Salon Branch Location',
            city: '',
            state: '',
            pincode: '',
          );

      final result = await repository.getBookingSummary(
        service: service,
        package: package,
        address: safeAddress,
        date: date,
        timeSlot: timeSlot,
        discount: _discount,
        taxRate: _taxRate,
      );

      final updatedWithBranch = result.copyWith(
        branch: branch,
        appliedCoupon: _appliedCoupon,
        stylistId: stylistId,
        stylistName: stylistName,
        chairNumber: chairNumber,
        productId: productId,
      );

      _summaryState = ViewState.success(updatedWithBranch);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _summaryState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  void updateStylist(String stylistId, String stylistName) {
    final current = summary;
    if (current == null) return;
    final updated = current.copyWith(
      stylistId: stylistId,
      stylistName: stylistName,
    );
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  void updateChair(String chairNumber) {
    final current = summary;
    if (current == null) return;
    final updated = current.copyWith(chairNumber: chairNumber);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  // Directly set a pre-calculated or loaded summary model.
  void setSummary(BookingSummaryModel summary) {
    _summaryState = ViewState.success(summary);
    _discount = summary.pricing.discount;
    _taxRate = summary.pricing.taxRate;
    _appliedCoupon = summary.appliedCoupon;
    notifyListeners();
  }

  // Updates the salon branch in the summary.
  void updateBranch(BranchModel newBranch) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(branch: newBranch);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  // Updates the delivery address in the summary (for backward compatibility).
  void updateAddress(AddressModel newAddress) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(address: newAddress);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  // Updates the scheduled date and time slot in the summary.
  void updateSchedule(ServiceDateModel newDate, TimeSlotModel newSlot) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(scheduledDate: newDate, timeSlot: newSlot);

    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  List<Map<String, dynamic>> _buildBookingItems(BookingSummaryModel summary) {
    final servicePrice =
        summary.package?.price ?? summary.service.startingPrice;
    final item = <String, dynamic>{
      'serviceId': summary.service.id,
      'service': summary.service.id,
      'price': servicePrice,
      if (summary.package != null) 'packageId': summary.package!.id,
      if (summary.stylistId != null && summary.stylistId!.isNotEmpty) ...{
        'stylistId': summary.stylistId,
        'stylist': summary.stylistId,
      },
      if (summary.chairNumber != null && summary.chairNumber!.isNotEmpty)
        'chairNumber': summary.chairNumber,
      if (summary.productId != null && summary.productId!.isNotEmpty) ...{
        'productId': summary.productId,
        'product': summary.productId,
      } else if (_selectedProduct?.id != null &&
          _selectedProduct!.id.isNotEmpty) ...{
        'productId': _selectedProduct!.id,
        'product': _selectedProduct!.id,
      },
    };
    return [item];
  }

  /// Validates and applies a coupon code via backend validation and pricing APIs.
  Future<bool> applyCouponCode(
    String code, {
    BookingRepository? bookingRepo,
    CouponRepository? couponRepo,
  }) async {
    final current = summary;
    if (current == null) return false;

    final trimmedCode = code.trim().toUpperCase();
    if (trimmedCode.isEmpty) {
      _couponError = 'Please enter a coupon code.';
      notifyListeners();
      return false;
    }

    _isApplyingCoupon = true;
    _couponError = null;
    notifyListeners();

    final effectiveCouponRepo = couponRepo ?? couponRepository;
    final effectiveBookingRepo = bookingRepo ?? bookingRepository;

    try {
      final currentSubtotal = current.pricing.packagePrice > 0
          ? current.pricing.packagePrice
          : (current.package?.price ?? current.service.startingPrice);

      ValidateCouponResponseModel? validationResult;
      String? backendValidationMessage;

      if (effectiveCouponRepo != null) {
        try {
          validationResult = await effectiveCouponRepo.validateCoupon(
            code: trimmedCode,
            subtotal: currentSubtotal,
          );
          backendValidationMessage = validationResult.message;
        } on ApiException catch (e) {
          _couponError = e.message;
          _isApplyingCoupon = false;
          notifyListeners();
          return false;
        } catch (e) {
          if (effectiveBookingRepo == null) {
            final appError = ErrorHandler.handleError(e);
            _couponError = appError.message;
            _isApplyingCoupon = false;
            notifyListeners();
            return false;
          }
        }
      }

      if (effectiveBookingRepo != null && current.branch?.id != null) {
        final items = _buildBookingItems(current);

        final pricing = await effectiveBookingRepo.calculatePricing(
          branchId: current.branch!.id,
          date: current.scheduledDate.date.toIso8601String().split('T').first,
          timeSlot: current.timeSlot.bookingTimeSlot,
          items: items,
          couponCode: trimmedCode,
        );


        final effectiveDiscount = pricing.couponDiscount > 0
            ? pricing.couponDiscount
            : (pricing.discount > 0
                  ? pricing.discount
                  : (validationResult?.discountAmount ?? 0.0));

        if (effectiveDiscount <= 0) {
          _couponError =
              backendValidationMessage ??
              'Coupon could not be applied to this booking.';
          _isApplyingCoupon = false;
          notifyListeners();
          return false;
        }

        final appliedCouponModel = CouponModel(
          code: trimmedCode,
          title: validationResult?.message ?? '$trimmedCode Applied',
          description:
              'Backend verified promo discount of ₹${effectiveDiscount.toStringAsFixed(0)}',
          flatDiscount: effectiveDiscount,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
        );

        _appliedCoupon = appliedCouponModel;
        _discount = effectiveDiscount;
        _couponError = null;

        final newPricing = PricingBreakdown(
          packagePrice: pricing.subtotal > 0
              ? pricing.subtotal
              : currentSubtotal,
          discount: effectiveDiscount,
          taxAmount: pricing.tax,
          taxRate: pricing.subtotal > 0
              ? (pricing.tax / pricing.subtotal)
              : _taxRate,
          totalAmount: pricing.total,
        );

        final updated = current.copyWith(
          pricing: newPricing,
          appliedCoupon: appliedCouponModel,
        );

        _summaryState = ViewState.success(updated);
        _isApplyingCoupon = false;
        notifyListeners();
        return true;
      } else {
        // Fallback when booking repository is not available
        final discountAmount = validationResult?.discountAmount ?? 0.0;
        if (discountAmount <= 0) {
          _couponError = 'Coupon could not be applied.';
          _isApplyingCoupon = false;
          notifyListeners();
          return false;
        }

        final appliedCouponModel = CouponModel(
          code: trimmedCode,
          title: '$trimmedCode Applied',
          description: 'Promotional discount',
          flatDiscount: discountAmount,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
        );

        _appliedCoupon = appliedCouponModel;
        _discount = discountAmount;
        _couponError = null;

        final newPricing = PricingBreakdown.calculate(
          packagePrice: currentSubtotal,
          discount: discountAmount,
          taxRate: _taxRate,
        );

        final updated = current.copyWith(
          pricing: newPricing,
          appliedCoupon: appliedCouponModel,
        );

        _summaryState = ViewState.success(updated);
        _isApplyingCoupon = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _couponError = appError.message;
      _isApplyingCoupon = false;
      notifyListeners();
      return false;
    }
  }

  // Backward-compatible synchronous/model-based coupon apply
  void applyCoupon(CouponModel coupon) {
    applyCouponCode(coupon.code);
  }

  // Remove currently applied coupon and restore un-discounted pricing.
  Future<void> removeCoupon({BookingRepository? bookingRepo}) async {
    final current = summary;
    if (current == null) return;

    _appliedCoupon = null;
    _discount = 0.0;
    _couponError = null;

    final effectiveBookingRepo = bookingRepo ?? bookingRepository;
    if (effectiveBookingRepo != null && current.branch?.id != null) {
      try {
        final items = _buildBookingItems(current);
        final pricing = await effectiveBookingRepo.calculatePricing(
          branchId: current.branch!.id,
          date: current.scheduledDate.date.toIso8601String().split('T').first,
          timeSlot: current.timeSlot.bookingTimeSlot,
          items: items,
          couponCode: null,
        );

        final newPricing = PricingBreakdown(
          packagePrice: pricing.subtotal,
          discount: 0.0,
          taxAmount: pricing.tax,
          taxRate: pricing.subtotal > 0
              ? (pricing.tax / pricing.subtotal)
              : _taxRate,
          totalAmount: pricing.total,
        );

        final updated = current.copyWith(
          pricing: newPricing,
          clearAppliedCoupon: true,
        );
        _summaryState = ViewState.success(updated);
        notifyListeners();
        return;
      } catch (_) {
        // Fall back to local calculation if network call fails
      }
    }

    final bookingPrice =
        current.package?.price ?? current.service.startingPrice;
    final newPricing = PricingBreakdown.calculate(
      packagePrice: bookingPrice,
      discount: 0.0,
      taxRate: _taxRate,
    );

    final updated = current.copyWith(
      pricing: newPricing,
      clearAppliedCoupon: true,
    );

    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  // Updates package and recalculates pricing breakdown.
  Future<void> updatePackage(ServicePackageModel newPackage) async {
    final current = summary;
    if (current == null) return;

    await loadSummary(
      service: current.service,
      package: newPackage,
      address: current.address,
      branch: current.branch,
      date: current.scheduledDate,
      timeSlot: current.timeSlot,
      discount: _discount,
      taxRate: _taxRate,
    );
  }

  // Clears the summary state.
  void clear() {
    _summaryState = ViewState.initial();
    _discount = 0.0;
    _appliedCoupon = null;
    _couponError = null;
    _selectedProduct = null;
    notifyListeners();
  }
}
