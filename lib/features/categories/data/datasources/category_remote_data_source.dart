import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
}

/// Production implementation communicating with REST API via ApiService
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiService apiService;

  CategoryRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiService.get<List<CategoryModel>>(
      ApiConstants.categories,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final response = await apiService.get<CategoryModel>(
      ApiConstants.categoryById(id),
      fromJson: (json) => CategoryModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw NotFoundException(message: 'Category with id $id not found');
    }
    return response.data!;
  }
}

/// TEMPORARY: Isolated mock data source until live REST backend is deployed.
class MockCategoryRemoteDataSource implements CategoryRemoteDataSource {
  final List<CategoryModel> _mockCategories = [
    const CategoryModel(
      id: 'cat_hair_styling',
      name: 'Haircut & Styling',
      description: 'Precision haircuts, blow-drys, texture styling, and keratin care',
      image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500',
      icon: 'content_cut',
      displayOrder: 1,
    ),
    const CategoryModel(
      id: 'cat_hair_color',
      name: 'Hair Color & Highlights',
      description: 'Balayage, ombre, root touch-ups, global coloring, and glossing',
      image: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500',
      icon: 'palette',
      displayOrder: 2,
    ),
    const CategoryModel(
      id: 'cat_facial',
      name: 'Facials & Skincare',
      description: 'Hydra facials, brightening clean-ups, anti-aging, and skin detox',
      image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=500',
      icon: 'face',
      displayOrder: 3,
    ),
    const CategoryModel(
      id: 'cat_spa',
      name: 'Hair & Scalp Spa',
      description: 'Deep conditioning, Moroccan oil treatment, anti-dandruff detox',
      image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500',
      icon: 'spa',
      displayOrder: 4,
    ),
    const CategoryModel(
      id: 'cat_nails',
      name: 'Manicure & Pedicure',
      description: 'Classic & gel manicures, luxury foot spas, nail extensions & art',
      image: 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=500',
      icon: 'brush',
      displayOrder: 5,
    ),
    const CategoryModel(
      id: 'cat_bridal',
      name: 'Bridal & Party Makeup',
      description: 'HD bridal makeup, airbrush, party look, saree draping, & styling',
      image: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
      icon: 'auto_fix_high',
      displayOrder: 6,
    ),
    const CategoryModel(
      id: 'cat_grooming',
      name: "Men's Beard & Grooming",
      description: 'Beard trimming, royal shave, scalp massage, and executive styling',
      image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500',
      icon: 'content_cut',
      displayOrder: 7,
    ),
    // Backward compatibility for legacy tests
    const CategoryModel(
      id: 'cat_cleaning',
      name: 'Home Cleaning',
      description: 'Salon and home sanitization care',
      image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      icon: 'cleaning_services',
      displayOrder: 8,
    ),
    const CategoryModel(
      id: 'cat_appliances',
      name: 'Appliance Repair',
      description: 'Salon equipment care',
      image: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
      icon: 'build',
      displayOrder: 9,
    ),
  ];

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockCategories.where((c) => c.isActive).toList();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _mockCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      throw NotFoundException(message: 'Category with id $id not found');
    }
  }
}
