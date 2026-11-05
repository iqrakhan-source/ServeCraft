
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';

import '../models/service_products_response.dart';

abstract class ServiceProductsRemoteDataSource {
  Future<ServiceProductsResponse> getProductsForService(
      String serviceId,
      );
}

class ServiceProductsRemoteDataSourceImpl
    implements ServiceProductsRemoteDataSource {
  final ApiClient apiService;

  ServiceProductsRemoteDataSourceImpl({
    required this.apiService,
  });

  @override
  Future<ServiceProductsResponse> getProductsForService(
      String serviceId,
      ) async {
    final id = serviceId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Service ID cannot be empty');
    }

    final response = await apiService.get<ServiceProductsResponse>(
      '${ApiConstants.productsForService}/${Uri.encodeComponent(id)}',
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException(
            'Invalid products API response format',
          );
        }

        return ServiceProductsResponse.fromJson({
          'success': true,
          'data': Map<String, dynamic>.from(json),
        });
      },
    );


    if (response.data == null) {
      throw const ServerException(
        message: 'The products API returned an empty response.',
      );
    }

    if (!response.data!.success) {
      throw ServerException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch products for service.',
      );
      // HTTP 200 with a valid response is sufficient here.
// The API uses count + data.products, not root-level success.
      return response.data!;
    }

    return response.data!;
  }
}
