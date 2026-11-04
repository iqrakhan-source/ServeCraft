import 'package:flutter/foundation.dart';

import '../../model/models/coupon_model.dart';
import '../../domain/repositories/coupon_repository.dart';

class OfferProvider extends ChangeNotifier {
  final CouponRepository repository;

  OfferProvider({
    required this.repository,
  });

  List<CouponModel> _offers = [];

  CouponModel? _appliedCoupon;
  String? _couponError;
  String? _error;
  bool _isLoading = false;

  List<CouponModel> get offers => _offers;
  CouponModel? get appliedCoupon => _appliedCoupon;
  String? get couponError => _couponError;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offers = await repository.getCoupons();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CouponModel? validateCoupon(String code, double bookingSubtotal) {
    _couponError = null;

    final match = _offers.firstWhere(
          (c) =>
      c.code.toUpperCase() == code.trim().toUpperCase() &&
          c.isActive,
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
      'Coupon requires a minimum booking amount of ₹${match.minBookingAmount.toInt()}.';
      notifyListeners();
      return null;
    }

    _appliedCoupon = match;
    notifyListeners();
    return match;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}