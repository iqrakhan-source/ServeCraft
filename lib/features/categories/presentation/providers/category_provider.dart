import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository repository;

  ViewState<List<CategoryModel>> _categoriesState = ViewState.initial();
  CategoryModel? _selectedCategory;

  CategoryProvider({required this.repository});

  ViewState<List<CategoryModel>> get categoriesState => _categoriesState;
  List<CategoryModel> get categories => _categoriesState.data ?? [];
  CategoryModel? get selectedCategory => _selectedCategory;

  bool get isLoading => _categoriesState.isLoading;
  bool get hasError => _categoriesState.isError;
  bool get isEmpty => _categoriesState.isEmpty;
  String? get errorMessage => _categoriesState.errorMessage;

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _categoriesState.isSuccess && categories.isNotEmpty) {
      return;
    }

    _categoriesState = ViewState.loading();
    notifyListeners();

    try {
      final result = await repository.getCategories();
      if (result.isEmpty) {
        _categoriesState = ViewState.empty();
      } else {
        // Sort by display order
        result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        _categoriesState = ViewState.success(result);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _categoriesState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }
}
