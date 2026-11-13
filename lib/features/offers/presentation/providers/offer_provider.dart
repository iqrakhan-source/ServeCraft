import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import '../../data/models/coupon_model.dart';
import '../../data/models/validate_coupon_response_model.dart';
import '../../domain/repositories/coupon_repository.dart';

class OfferProvider extends ChangeNotifier {
  final CouponRepository repository;

  OfferProvider({required this.repository});

  List<CouponModel> _offers = [];

  CouponModel? _appliedCoupon;
  ValidateCouponResponseModel? _validationResult;
  String? _couponError;
  String? _error;
  bool _isLoading = false;
  bool _isValidating = false;

  List<CouponModel> get offers => _offers;
  CouponModel? get appliedCoupon => _appliedCoupon;
  ValidateCouponResponseModel? get validationResult => _validationResult;
  String? get couponError => _couponError;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isValidating => _isValidating;

  Future<void> loadCoupons({String? branchId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offers = await repository.getCoupons(branchId: branchId);
    } catch (e) {
      _error = ErrorHandler.handleError(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Offline validation helper using locally cached coupons
  CouponModel? validateCoupon(String code, double bookingSubtotal) {
    _couponError = null;

    final match = _offers.firstWhere(
      (c) => c.code.toUpperCase() == code.trim().toUpperCase() && c.isActive,
      orElse: () => CouponModel(
        code: '',
        title: '',
        description: '',
        expiryDate: DateTime.now(),
        isActive: false,
      ),
    );

    if (match.code.isEmpty) {
      _couponError = 'Invalid coupon code. Please check and try again.';
      notifyListeners();
      return null;
    }

    if (bookingSubtotal < match.minBookingAmount) {
      _couponError =
          'Coupon requires a minimum booking amount of ${AppFormatters.formatCurrency(match.minBookingAmount)}.';
      notifyListeners();
      return null;
    }

    _appliedCoupon = match;
    notifyListeners();
    return match;
  }

  /// Online API-verified coupon validation per Section 7.2
  Future<ValidateCouponResponseModel?> validateCouponOnline({
    required String code,
    required double subtotal,
  }) async {
    _isValidating = true;
    _couponError = null;
    notifyListeners();

    try {
      final result = await repository.validateCoupon(
        code: code,
        subtotal: subtotal,
      );
      _validationResult = result;

      // Also set applied coupon if matching
      final match = _offers.firstWhere(
        (c) => c.code.toUpperCase() == code.trim().toUpperCase(),
        orElse: () => CouponModel(
          code: code.trim().toUpperCase(),
          title: 'Coupon Applied',
          description: 'Verified promo discount',
          flatDiscount: result.discountAmount,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );
      _appliedCoupon = match;

      return result;
    } catch (e) {
      _couponError = ErrorHandler.handleError(e).message;
      _appliedCoupon = null;
      _validationResult = null;
      return null;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _validationResult = null;
    _couponError = null;
    notifyListeners();
  }
}
