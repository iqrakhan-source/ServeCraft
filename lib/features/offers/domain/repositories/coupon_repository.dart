import '../../data/models/coupon_model.dart';
import '../../data/models/validate_coupon_response_model.dart';

abstract class CouponRepository {
  Future<List<CouponModel>> getCoupons({String? branchId});
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  });
}
