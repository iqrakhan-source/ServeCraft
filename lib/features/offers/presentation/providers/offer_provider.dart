import 'package:flutter/foundation.dart';
import '../../data/models/coupon_model.dart';

class OfferProvider extends ChangeNotifier {
  final List<CouponModel> _offers = [
    CouponModel(
      code: 'WELCOME50',
      title: 'Flat ₹50 Off on First Appointment',
      description: 'Valid on any salon haircut, grooming, or facial booking.',
      flatDiscount: 50.0,
      minBookingAmount: 299.0,
      expiryDate: DateTime.now().add(const Duration(days: 60)),
    ),
    CouponModel(
      code: 'GLOW20',
      title: '20% Off on Luxury Facials & Spa',
      description: 'Get 20% discount up to ₹300 on Hydra facials, hair spas, and massage therapies.',
      discountPercent: 20.0,
      maxDiscount: 300.0,
      minBookingAmount: 799.0,
      expiryDate: DateTime.now().add(const Duration(days: 45)),
    ),
    CouponModel(
      code: 'LUXE500',
      title: 'Flat ₹500 Off on Premium Combos',
      description: 'Valid on bridal packages, hair color transformations, and deluxe combos above ₹2,000.',
      flatDiscount: 500.0,
      minBookingAmount: 2000.0,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  CouponModel? _appliedCoupon;
  String? _couponError;

  List<CouponModel> get offers => _offers;
  CouponModel? get appliedCoupon => _appliedCoupon;
  String? get couponError => _couponError;

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
