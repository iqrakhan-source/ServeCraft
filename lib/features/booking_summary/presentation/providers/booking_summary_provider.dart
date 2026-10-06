import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/offers/data/models/coupon_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../../data/models/booking_summary_model.dart';
import '../../data/models/pricing_breakdown_model.dart';
import '../../domain/repositories/booking_summary_repository.dart';

class BookingSummaryProvider extends ChangeNotifier {
  final BookingSummaryRepository repository;

  ViewState<BookingSummaryModel> _summaryState = ViewState.initial();
  double _discount = 0.0;
  double _taxRate = PricingBreakdown.defaultTaxRate;
  CouponModel? _appliedCoupon;
  String? _couponError;

  BookingSummaryProvider({required this.repository});

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

  /// Loads or calculates a full booking summary with all selections
  Future<void> loadSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    AddressModel? address,
    BranchModel? branch,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double? discount,
    double? taxRate,
  }) async {
    _discount = discount ?? _discount;
    _taxRate = taxRate ?? _taxRate;

    _summaryState = ViewState.loading();
    notifyListeners();

    try {
      final safeAddress = address ??
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

  /// Directly set a pre-calculated or loaded summary model
  void setSummary(BookingSummaryModel summary) {
    _summaryState = ViewState.success(summary);
    _discount = summary.pricing.discount;
    _taxRate = summary.pricing.taxRate;
    _appliedCoupon = summary.appliedCoupon;
    notifyListeners();
  }

  /// Updates the salon branch in the summary
  void updateBranch(BranchModel newBranch) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(branch: newBranch);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Updates the delivery address in the summary (for backward compatibility)
  void updateAddress(AddressModel newAddress) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(address: newAddress);
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Updates the scheduled date and time slot in the summary
  void updateSchedule(ServiceDateModel newDate, TimeSlotModel newSlot) {
    final current = summary;
    if (current == null) return;

    final updated = current.copyWith(
      scheduledDate: newDate,
      timeSlot: newSlot,
    );
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Apply a salon discount coupon
  void applyCoupon(CouponModel coupon) {
    final current = summary;
    if (current == null) return;

    final discountAmount = coupon.calculateDiscount(current.package.price);
    if (discountAmount <= 0) {
      _couponError =
          'Booking minimum of ₹${coupon.minBookingAmount.toInt()} not met for this coupon.';
      notifyListeners();
      return;
    }

    _appliedCoupon = coupon;
    _discount = discountAmount;
    _couponError = null;

    final newPricing = PricingBreakdown.calculate(
      packagePrice: current.package.price,
      discount: discountAmount,
      taxRate: _taxRate,
    );

    final updated = current.copyWith(
      pricing: newPricing,
      appliedCoupon: coupon,
    );
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Remove currently applied coupon
  void removeCoupon() {
    final current = summary;
    if (current == null) return;

    _appliedCoupon = null;
    _discount = 0.0;
    _couponError = null;

    final newPricing = PricingBreakdown.calculate(
      packagePrice: current.package.price,
      discount: 0.0,
      taxRate: _taxRate,
    );

    final updated = current.copyWith(
      pricing: newPricing,
      appliedCoupon: null,
    );
    _summaryState = ViewState.success(updated);
    notifyListeners();
  }

  /// Updates package and recalculates pricing breakdown
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

  /// Clears the summary state
  void clear() {
    _summaryState = ViewState.initial();
    _discount = 0.0;
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}
