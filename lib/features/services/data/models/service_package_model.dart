class ServicePackageModel {
  final String id;
  final String serviceId;
  final String name;
  final String description;
  final double price;
  final String duration;
  final List<String> features;
  final bool isActive;

  const ServicePackageModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isActive = true,
  });

  ServicePackageModel copyWith({
    String? id,
    String? serviceId,
    String? name,
    String? description,
    double? price,
    String? duration,
    List<String>? features,
    bool? isActive,
  }) {
    return ServicePackageModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFeatures = [];
    if (json['features'] is List) {
      parsedFeatures = (json['features'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return ServicePackageModel(
      id: json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as String? ?? '60 mins',
      features: parsedFeatures,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'features': features,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServicePackageModel &&
        other.id == id &&
        other.serviceId == serviceId &&
        other.name == name &&
        other.price == price;
  }

  @override
  int get hashCode => Object.hash(id, serviceId, name, price);
}
