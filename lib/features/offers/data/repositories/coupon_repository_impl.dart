
import '../../datasources/coupon_remote_data_source.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../model/models/coupon_model.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CouponModel>> getCoupons() {
    return remoteDataSource.getCoupons();
  }
}
