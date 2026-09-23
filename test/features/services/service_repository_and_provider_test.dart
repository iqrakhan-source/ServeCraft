import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/services/data/datasources/service_remote_data_source.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'package:prop_crm/features/services/data/repositories/service_repository_impl.dart';
import 'package:prop_crm/features/services/presentation/providers/service_details_provider.dart';
import 'package:prop_crm/features/services/presentation/providers/service_provider.dart';

class FakeFailingServiceDataSource implements ServiceRemoteDataSource {
  @override
  Future<List<ServiceModel>> getServices({String? categoryId, String? query}) async {
    throw Exception('Failed to load services from network');
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    throw Exception('Service $id not found');
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(String serviceId) async {
    throw Exception('Packages not found');
  }
}

class FakeEmptyServiceDataSource implements ServiceRemoteDataSource {
  @override
  Future<List<ServiceModel>> getServices({String? categoryId, String? query}) async {
    return [];
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    throw Exception('Not found');
  }

  @override
  Future<List<ServicePackageModel>> getPackagesByServiceId(String serviceId) async {
    return [];
  }
}

void main() {
  group('Service Repository & Provider Tests', () {
    test('ServiceRepositoryImpl fetches all and category-filtered services', () async {
      final dataSource = MockServiceRemoteDataSource();
      final repository = ServiceRepositoryImpl(remoteDataSource: dataSource);

      final allServices = await repository.getServices();
      expect(allServices, isNotEmpty);

      final cleaningServices =
          await repository.getServices(categoryId: 'cat_cleaning');
      expect(cleaningServices, isNotEmpty);
      expect(cleaningServices.every((s) => s.categoryId == 'cat_cleaning'), isTrue);

      final service = await repository.getServiceById(allServices.first.id);
      expect(service.id, equals(allServices.first.id));
      expect(service.packages, isNotEmpty);
    });

    test('ServiceProvider transitions to loading then success', () async {
      final dataSource = MockServiceRemoteDataSource();
      final repository = ServiceRepositoryImpl(remoteDataSource: dataSource);
      final provider = ServiceProvider(repository: repository);

      expect(provider.isLoading, isFalse);

      final future = provider.fetchServices();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.services, isNotEmpty);
    });

    test('ServiceProvider client search filters correctly without mutating source list', () async {
      final dataSource = MockServiceRemoteDataSource();
      final repository = ServiceRepositoryImpl(remoteDataSource: dataSource);
      final provider = ServiceProvider(repository: repository);

      await provider.fetchServices();
      final totalCount = provider.services.length;

      // Search for specific service
      await provider.searchServices('Kitchen');
      expect(provider.services.length, lessThanOrEqualTo(totalCount));
      expect(
        provider.services.every(
          (s) => s.name.toLowerCase().contains('kitchen') ||
                 s.description.toLowerCase().contains('kitchen'),
        ),
        isTrue,
      );

      // Clear search
      await provider.clearFilter();
      expect(provider.services.length, equals(totalCount));
    });

    test('ServiceProvider handles empty and error states cleanly', () async {
      final emptyDataSource = FakeEmptyServiceDataSource();
      final emptyRepo = ServiceRepositoryImpl(remoteDataSource: emptyDataSource);
      final emptyProvider = ServiceProvider(repository: emptyRepo);

      await emptyProvider.fetchServices();
      expect(emptyProvider.isEmpty, isTrue);

      final failingDataSource = FakeFailingServiceDataSource();
      final failingRepo = ServiceRepositoryImpl(remoteDataSource: failingDataSource);
      final failingProvider = ServiceProvider(repository: failingRepo);

      await failingProvider.fetchServices();
      expect(failingProvider.hasError, isTrue);
      expect(failingProvider.errorMessage, isNotNull);
    });

    test('ServiceDetailsProvider fetches details and selects default package', () async {
      final dataSource = MockServiceRemoteDataSource();
      final repository = ServiceRepositoryImpl(remoteDataSource: dataSource);
      final detailsProvider = ServiceDetailsProvider(repository: repository);

      final services = await repository.getServices();
      final targetService = services.first;

      await detailsProvider.fetchServiceDetails(targetService.id);

      expect(detailsProvider.isLoading, isFalse);
      expect(detailsProvider.hasError, isFalse);
      expect(detailsProvider.service, isNotNull);
      expect(detailsProvider.service!.id, equals(targetService.id));
      expect(detailsProvider.selectedPackage, isNotNull);
      expect(detailsProvider.selectedPackage!.id,
          equals(targetService.packages.first.id));

      // Select other package if available
      if (targetService.packages.length > 1) {
        final secondPkg = targetService.packages[1];
        detailsProvider.selectPackage(secondPkg);
        expect(detailsProvider.selectedPackage!.id, equals(secondPkg.id));
      }
    });

    test('ServiceDetailsProvider handles not found error', () async {
      final dataSource = FakeFailingServiceDataSource();
      final repository = ServiceRepositoryImpl(remoteDataSource: dataSource);
      final detailsProvider = ServiceDetailsProvider(repository: repository);

      await detailsProvider.fetchServiceDetails('invalid_id');

      expect(detailsProvider.isLoading, isFalse);
      expect(detailsProvider.hasError, isTrue);
      expect(detailsProvider.service, isNull);
    });
  });
}
