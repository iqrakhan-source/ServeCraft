import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';
import '../models/service_model.dart';
import '../models/service_package_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? query,
  }) async {
    return await remoteDataSource.getServices(
      categoryId: categoryId,
      query: query,
    );
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    return await remoteDataSource.getServiceById(id);
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(
      String serviceId) async {
    return await remoteDataSource.getPackagesByServiceId(serviceId);
  }
}
