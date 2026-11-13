import '../../model/models/coupon_model.dart';
import '../../model/models/validate_coupon_response_model.dart';

abstract class CouponRepository {
  Future<List<CouponModel>> getCoupons({String? branchId});
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  });
}
