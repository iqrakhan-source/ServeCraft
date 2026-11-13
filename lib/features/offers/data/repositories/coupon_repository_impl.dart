import '../../domain/repositories/coupon_repository.dart';
import '../datasources/coupon_remote_data_source.dart';
import '../models/coupon_model.dart';
import '../models/validate_coupon_response_model.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CouponModel>> getCoupons({String? branchId}) {
    return remoteDataSource.getCoupons(branchId: branchId);
  }

  @override
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  }) {
    return remoteDataSource.validateCoupon(code: code, subtotal: subtotal);
  }
}
