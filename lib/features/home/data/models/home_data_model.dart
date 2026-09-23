import 'package:prop_crm/features/categories/data/models/category_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'banner_model.dart';

class HomeDataModel {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ServiceModel> popularServices;

  const HomeDataModel({
    required this.banners,
    required this.categories,
    required this.popularServices,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final banners = (json['banners'] as List?)
            ?.map((b) => BannerModel.fromJson(b as Map<String, dynamic>))
            .toList() ??
        [];

    final categories = (json['categories'] as List?)
            ?.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final popularServices = (json['popularServices'] as List?)
            ?.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return HomeDataModel(
      banners: banners,
      categories: categories,
      popularServices: popularServices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banners': banners.map((b) => b.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'popularServices': popularServices.map((s) => s.toJson()).toList(),
    };
  }
}
