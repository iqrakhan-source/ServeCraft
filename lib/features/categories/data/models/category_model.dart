class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? icon;
  final bool isActive;
  final int displayOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.icon,
    this.isActive = true,
    this.displayOrder = 0,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? icon,
    bool? isActive,
    int? displayOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'icon': icon,
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
