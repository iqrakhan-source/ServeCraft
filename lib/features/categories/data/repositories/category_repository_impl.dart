import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    return await remoteDataSource.getCategoryById(id);
  }
}
