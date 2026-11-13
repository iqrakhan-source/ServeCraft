class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final String? icon;
  final String gender;
  final bool isActive;
  final int displayOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.slug = '',
    required this.description,
    this.image,
    this.icon,
    this.gender = 'all',
    this.isActive = true,
    this.displayOrder = 0,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? icon,
    String? gender,
    bool? isActive,
    int? displayOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: (json['image'] ?? json['imageUrl']) as String?,
      icon: json['icon'] as String?,
      gender: json['gender'] as String? ?? 'all',
      isActive: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'imageUrl': image,
      'icon': icon,
      'gender': gender,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, name, isActive);
}
