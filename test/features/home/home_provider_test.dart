import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:prop_crm/features/home/data/datasources/home_remote_data_source.dart';
import 'package:prop_crm/features/home/data/models/home_data_model.dart';
import 'package:prop_crm/features/home/data/repositories/home_repository_impl.dart';
import 'package:prop_crm/features/home/presentation/providers/home_provider.dart';
import 'package:prop_crm/features/services/data/datasources/service_remote_data_source.dart';

class FakeFailingHomeDataSource implements HomeRemoteDataSource {
  @override
  Future<HomeDataModel> getHomeData() async {
    throw Exception('Failed to load home discovery recommendations');
  }
}

class FakeEmptyHomeDataSource implements HomeRemoteDataSource {
  @override
  Future<HomeDataModel> getHomeData() async {
    return const HomeDataModel(
      banners: [],
      categories: [],
      popularServices: [],
    );
  }
}

void main() {
  group('HomeProvider Tests', () {
    test('fetchHomeData loads banners, categories, and popular services successfully', () async {
      final categoryDataSource = MockCategoryRemoteDataSource();
      final serviceDataSource = MockServiceRemoteDataSource();
      final homeDataSource = MockHomeRemoteDataSource(
        categoryDataSource: categoryDataSource,
        serviceDataSource: serviceDataSource,
      );
      final homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
      final homeProvider = HomeProvider(repository: homeRepository);

      expect(homeProvider.isLoading, isFalse);

      final future = homeProvider.fetchHomeData();
      expect(homeProvider.isLoading, isTrue);

      await future;

      expect(homeProvider.isLoading, isFalse);
      expect(homeProvider.hasError, isFalse);
      expect(homeProvider.homeData, isNotNull);
      expect(homeProvider.homeData!.banners, isNotEmpty);
      expect(homeProvider.homeData!.categories, isNotEmpty);
      expect(homeProvider.homeData!.popularServices, isNotEmpty);
    });

    test('fetchHomeData sets empty state when data has no categories and services', () async {
      final homeDataSource = FakeEmptyHomeDataSource();
      final homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
      final homeProvider = HomeProvider(repository: homeRepository);

      await homeProvider.fetchHomeData();

      expect(homeProvider.isLoading, isFalse);
      expect(homeProvider.isEmpty, isTrue);
    });

    test('fetchHomeData sets error state on network failure', () async {
      final homeDataSource = FakeFailingHomeDataSource();
      final homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
      final homeProvider = HomeProvider(repository: homeRepository);

      await homeProvider.fetchHomeData();

      expect(homeProvider.isLoading, isFalse);
      expect(homeProvider.hasError, isTrue);
      expect(homeProvider.errorMessage, isNotNull);
    });

    test('updateLocation updates currentAddress correctly', () {
      final categoryDataSource = MockCategoryRemoteDataSource();
      final serviceDataSource = MockServiceRemoteDataSource();
      final homeDataSource = MockHomeRemoteDataSource(
        categoryDataSource: categoryDataSource,
        serviceDataSource: serviceDataSource,
      );
      final homeRepository = HomeRepositoryImpl(remoteDataSource: homeDataSource);
      final homeProvider = HomeProvider(repository: homeRepository);

      expect(homeProvider.currentAddress, contains('Indiranagar'));

      homeProvider.updateLocation('Office • Koramangala 4th Block, Bengaluru');
      expect(homeProvider.currentAddress, contains('Koramangala'));
    });
  });
}
