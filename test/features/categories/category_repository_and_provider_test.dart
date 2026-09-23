import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:prop_crm/features/categories/data/models/category_model.dart';
import 'package:prop_crm/features/categories/data/repositories/category_repository_impl.dart';
import 'package:prop_crm/features/categories/presentation/providers/category_provider.dart';

class FakeFailingCategoryDataSource implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    throw Exception('Server failed to fetch categories');
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    throw Exception('Category not found');
  }
}

class FakeEmptyCategoryDataSource implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return [];
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    throw Exception('Not found');
  }
}

void main() {
  group('Category Repository & Provider Tests', () {
    test('CategoryRepositoryImpl fetches categories from data source', () async {
      final dataSource = MockCategoryRemoteDataSource();
      final repository = CategoryRepositoryImpl(remoteDataSource: dataSource);

      final categories = await repository.getCategories();

      expect(categories, isNotEmpty);
      expect(categories.any((c) => c.name.contains('Cleaning')), isTrue);
    });

    test('CategoryProvider transitions to loading then success', () async {
      final dataSource = MockCategoryRemoteDataSource();
      final repository = CategoryRepositoryImpl(remoteDataSource: dataSource);
      final provider = CategoryProvider(repository: repository);

      expect(provider.isLoading, isFalse);
      expect(provider.categories, isEmpty);

      final future = provider.fetchCategories();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.categories, isNotEmpty);
      expect(provider.categories.length, greaterThanOrEqualTo(4));
    });

    test('CategoryProvider transitions to empty state when list is empty', () async {
      final dataSource = FakeEmptyCategoryDataSource();
      final repository = CategoryRepositoryImpl(remoteDataSource: dataSource);
      final provider = CategoryProvider(repository: repository);

      await provider.fetchCategories();

      expect(provider.isLoading, isFalse);
      expect(provider.isEmpty, isTrue);
      expect(provider.categories, isEmpty);
    });

    test('CategoryProvider transitions to error state on repository failure', () async {
      final dataSource = FakeFailingCategoryDataSource();
      final repository = CategoryRepositoryImpl(remoteDataSource: dataSource);
      final provider = CategoryProvider(repository: repository);

      await provider.fetchCategories();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, isNotNull);
    });

    test('CategoryProvider selectCategory updates selectedCategory state', () {
      final dataSource = MockCategoryRemoteDataSource();
      final repository = CategoryRepositoryImpl(remoteDataSource: dataSource);
      final provider = CategoryProvider(repository: repository);

      const category = CategoryModel(
        id: 'cat_test',
        name: 'Plumbing Service',
        description: 'Test description',
      );

      provider.selectCategory(category);
      expect(provider.selectedCategory, equals(category));

      provider.clearSelection();
      expect(provider.selectedCategory, isNull);
    });
  });
}
