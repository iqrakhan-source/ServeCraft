import 'service_package_model.dart';

class ServiceModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String? image;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String duration;
  final bool isActive;
  final List<ServicePackageModel> packages;
  final String genderTarget; // 'all', 'women', 'men'
  final List<String> inclusions;

  const ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.image,
    this.rating = 4.8,
    this.reviewCount = 0,
    required this.startingPrice,
    this.duration = '45 mins',
    this.isActive = true,
    this.packages = const [],
    this.genderTarget = 'all',
    this.inclusions = const [],
  });

  /// Parse duration into integer minutes for scheduling slot calculation
  int get durationInMinutes {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    if (match != null) {
      final value = int.parse(match.group(1)!);
      if (duration.toLowerCase().contains('hr') ||
          duration.toLowerCase().contains('hour')) {
        return value * 60;
      }
      return value;
    }
    return 45;
  }

  ServiceModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    String? image,
    double? rating,
    int? reviewCount,
    double? startingPrice,
    String? duration,
    bool? isActive,
    List<ServicePackageModel>? packages,
    String? genderTarget,
    List<String>? inclusions,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      startingPrice: startingPrice ?? this.startingPrice,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      packages: packages ?? this.packages,
      genderTarget: genderTarget ?? this.genderTarget,
      inclusions: inclusions ?? this.inclusions,
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    final String parsedCategoryId = category is Map
        ? (category['_id'] ?? category['id'] ?? '').toString()
        : (json['categoryId'] ?? '').toString();

    final rawDuration = json['duration'];
    final String parsedDuration = rawDuration is num
        ? '$rawDuration mins'
        : rawDuration?.toString() ?? '45 mins';

    final rawPrice = json['price'] ?? json['startingPrice'];

    final parsedPackages = json['packages'] is List
        ? (json['packages'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ServicePackageModel.fromJson)
        .toList()
        : <ServicePackageModel>[];

    final parsedInclusions = json['inclusions'] is List
        ? (json['inclusions'] as List)
        .map((item) => item.toString())
        .toList()
        : <String>[];

    return ServiceModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      categoryId: parsedCategoryId,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      startingPrice: (rawPrice as num?)?.toDouble() ?? 0.0,
      duration: parsedDuration,
      isActive: json['active'] as bool? ??
          json['isActive'] as bool? ??
          true,
      packages: parsedPackages,
      genderTarget: json['genderTarget'] as String? ?? 'all',
      inclusions: parsedInclusions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'startingPrice': startingPrice,
      'duration': duration,
      'isActive': isActive,
      'packages': packages.map((p) => p.toJson()).toList(),
      'genderTarget': genderTarget,
      'inclusions': inclusions,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.startingPrice == startingPrice;
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, startingPrice);
}
