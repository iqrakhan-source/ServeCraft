import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';

import '../model/models/coupon_model.dart';

abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getCoupons();
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient apiClient;

  CouponRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<CouponModel>> getCoupons() async {
    final response = await apiClient.get<List<CouponModel>>(
      ApiConstants.customerCoupons,
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw FormatException('Invalid coupons response');
        }

        final couponsJson = json['coupons'];

        if (couponsJson is! List) {
          throw FormatException('Coupons list not found');
        }

        return couponsJson
            .map(
              (item) => CouponModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
            .toList();
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? [];
  }
}