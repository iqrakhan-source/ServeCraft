import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import 'package:prop_crm/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:prop_crm/features/services/data/datasources/service_remote_data_source.dart';
import 'package:prop_crm/features/home/data/models/banner_model.dart';
import 'package:prop_crm/features/home/data/models/home_data_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData();
}

/// Production implementation connecting to REST backend via ApiService
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService apiService;

  HomeRemoteDataSourceImpl({required this.apiService});

  @override
  Future<HomeDataModel> getHomeData() async {
    final response = await apiService.get<HomeDataModel>(
      ApiConstants.home,
      fromJson: (json) => HomeDataModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data ??
        const HomeDataModel(
          banners: [],
          categories: [],
          popularServices: [],
        );
  }
}

/// TEMPORARY: Isolated mock data source until live REST backend is deployed.
class MockHomeRemoteDataSource implements HomeRemoteDataSource {
  final CategoryRemoteDataSource categoryDataSource;
  final ServiceRemoteDataSource serviceDataSource;

  MockHomeRemoteDataSource({
    required this.categoryDataSource,
    required this.serviceDataSource,
  });

  final List<BannerModel> _mockBanners = [
    const BannerModel(
      id: 'ban_1',
      title: 'Spring Cleaning Extravaganza',
      subtitle: 'Flat 20% off on all deep cleaning packages',
      discountTag: 'SAVE20',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
    ),
    const BannerModel(
      id: 'ban_2',
      title: 'Beat the Summer Heat',
      subtitle: 'AC Power Jet Servicing starting at just ₹599',
      discountTag: 'COOLING',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
    ),
    const BannerModel(
      id: 'ban_3',
      title: 'Salon At Home for Women & Men',
      subtitle: 'Relaxing spa, haircut, and grooming treatments',
      discountTag: 'GLOW50',
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
    ),
  ];

  @override
  Future<HomeDataModel> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 350));

    final categories = await categoryDataSource.getCategories();
    final services = await serviceDataSource.getServices();

    return HomeDataModel(
      banners: _mockBanners,
      categories: categories,
      popularServices: services,
    );
  }
}
