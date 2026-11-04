
import '../../model/models/coupon_model.dart';

abstract class CouponRepository {
  Future<List<CouponModel>> getCoupons();
}
