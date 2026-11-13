import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
}

/// Production implementation communicating with REST API via ApiService
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiService;

  CategoryRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiService.get<List<CategoryModel>>(
      ApiConstants.categories,
      fromJson: (json) {
        dynamic categoriesJson;

        if (json is List) {
          categoriesJson = json;
        } else if (json is Map) {
          categoriesJson =
              json['categories'] ??
              json['data']?['categories'] ??
              json['data'] ??
              json['results'];
        }

        if (categoriesJson is! List) {
          return <CategoryModel>[];
        }

        return categoriesJson.map((item) {
          if (item is Map) {
            return CategoryModel.fromJson(Map<String, dynamic>.from(item));
          }
          throw const FormatException('Invalid category item in API response.');
        }).toList();
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
