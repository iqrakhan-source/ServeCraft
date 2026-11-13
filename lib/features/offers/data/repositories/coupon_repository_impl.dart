import 'package:prop_crm/features/offers/datasources/coupon_remote_data_source.dart';
import 'package:prop_crm/features/offers/domain/repositories/coupon_repository.dart';
import 'package:prop_crm/features/offers/model/models/coupon_model.dart';
import 'package:prop_crm/features/offers/model/models/validate_coupon_response_model.dart';

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
