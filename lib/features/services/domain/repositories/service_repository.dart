import '../../data/models/service_model.dart';
import '../../data/models/service_package_model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices({String? categoryId, String? query});
  Future<ServiceModel> getServiceById(String id);
  Future<List<ServicePackageModel>> getPackagesByServiceId(String serviceId);
}
