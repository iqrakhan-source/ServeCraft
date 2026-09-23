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
      id: 'cat_cleaning',
      name: 'Home Cleaning',
      description: 'Deep cleaning, dusting, and sanitization for your home',
      image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      icon: 'cleaning_services',
      displayOrder: 1,
    ),
    const CategoryModel(
      id: 'cat_appliances',
      name: 'Appliance Repair',
      description: 'Expert servicing for ACs, fridges, washing machines & microwaves',
      image: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
      icon: 'build',
      displayOrder: 2,
    ),
    const CategoryModel(
      id: 'cat_electrician',
      name: 'Electrician',
      description: 'Switchboard installation, light fittings, wiring repairs',
      image: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
      icon: 'bolt',
      displayOrder: 3,
    ),
    const CategoryModel(
      id: 'cat_plumbing',
      name: 'Plumbing',
      description: 'Pipe leakage, tap fittings, water motor, and drain cleaning',
      image: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500',
      icon: 'plumbing',
      displayOrder: 4,
    ),
    const CategoryModel(
      id: 'cat_painting',
      name: 'Painting',
      description: 'Full house painting, accent walls, and waterproofing solutions',
      image: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=500',
      icon: 'format_paint',
      displayOrder: 5,
    ),
    const CategoryModel(
      id: 'cat_carpentry',
      name: 'Carpentry',
      description: 'Furniture assembly, lock repair, shelf fixing, and woodwork',
      image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500',
      icon: 'handyman',
      displayOrder: 6,
    ),
    const CategoryModel(
      id: 'cat_pest_control',
      name: 'Pest Control',
      description: 'Cockroach, bed bug, termite, and mosquito pest control',
      image: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=500',
      icon: 'pest_control',
      displayOrder: 7,
    ),
    const CategoryModel(
      id: 'cat_grooming',
      name: 'Salon & Spa',
      description: 'Haircut, facial, pedicure, and relaxing massages at home',
      image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500',
      icon: 'spa',
      displayOrder: 8,
    ),
  ];

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories.where((c) => c.isActive).toList();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      throw NotFoundException(message: 'Category with id $id not found');
    }
  }
}
