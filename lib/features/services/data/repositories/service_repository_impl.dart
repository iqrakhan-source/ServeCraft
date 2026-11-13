import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';
import '../datasources/service_products_remote_data_source.dart';
import '../models/service_model.dart';
import '../models/service_package_model.dart';
import '../models/service_products_response.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  final ServiceProductsRemoteDataSource? productsRemoteDataSource;

  ServiceRepositoryImpl({
    required this.remoteDataSource,
    this.productsRemoteDataSource,
  });

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? branchId,
    String? gender,
    String? query,
  }) async {
    return remoteDataSource.getServices(
      categoryId: categoryId,
      branchId: branchId,
      gender: gender,
      query: query,
    );
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    return remoteDataSource.getServiceById(id);
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(
    String serviceId,
  ) async {
    return remoteDataSource.getPackagesByServiceId(serviceId);
  }

  @override
  Future<ServiceProductsResponse> getProductsForService(String serviceId) {
    final dataSource = productsRemoteDataSource;

    if (dataSource == null) {
      throw StateError('Service products data source has not been configured.');
    }

    return dataSource.getProductsForService(serviceId);
  }
}
