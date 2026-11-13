import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../model/models/coupon_model.dart';
import '../model/models/validate_coupon_response_model.dart';

abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getCoupons({String? branchId});
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  });
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiClient apiClient;

  CouponRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CouponModel>> getCoupons({String? branchId}) async {
    final queryParameters = <String, dynamic>{};
    if (branchId != null && branchId.trim().isNotEmpty) {
      queryParameters['branchId'] = branchId.trim();
    }

    final response = await apiClient.get<List<CouponModel>>(
      ApiConstants.customerCoupons,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      fromJson: (json) {
        dynamic couponsJson;

        if (json is List) {
          couponsJson = json;
        } else if (json is Map) {
          couponsJson = json['data'] ?? json['coupons'];
        }

        if (couponsJson is! List) {
          return <CouponModel>[];
        }

        return couponsJson
            .whereType<Map>()
            .map(
              (item) => CouponModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      },
    );

    if (!response.success) {
      throw UnexpectedException(message: response.message);
    }

    return response.data ?? [];
  }

  @override
  Future<ValidateCouponResponseModel> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    final response = await apiClient.post<ValidateCouponResponseModel>(
      ApiConstants.validateCoupon,
      data: {'code': cleanCode, 'subtotal': subtotal},
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('Invalid coupon validation response');
        }
        return ValidateCouponResponseModel.fromJson(
          Map<String, dynamic>.from(json),
        );
      },
    );

    if (!response.success || response.data == null) {
      throw UnexpectedException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Coupon validation failed.',
      );
    }

    return response.data!;
  }
}
