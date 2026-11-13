class BranchModel {
  final String id;
  final String name;
  final String code;
  final String city;
  final String address;
  final String phone;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<int> workingDays; // 1 = Monday, 7 = Sunday
  final String openingTime; // '09:00'
  final String closingTime; // '21:00'
  final int totalChairs;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final List<String> amenities;

  const BranchModel({
    required this.id,
    required this.name,
    this.code = '',
    this.city = '',
    required this.address,
    required this.phone,
    this.imageUrl,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.workingDays = const [1, 2, 3, 4, 5, 6, 7],
    this.openingTime = '09:00',
    this.closingTime = '21:00',
    this.totalChairs = 10,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.amenities = const ['AC', 'Free Wi-Fi', 'Beverages', 'Valet Parking'],
  });

  bool isOpenOn(int weekday) => workingDays.contains(weekday);
  String get formattedHours => '$openingTime - $closingTime';

  BranchModel copyWith({
    String? id,
    String? name,
    String? code,
    String? city,
    String? address,
    String? phone,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<int>? workingDays,
    String? openingTime,
    String? closingTime,
    int? totalChairs,
    double? distanceKm,
    double? latitude,
    double? longitude,
    bool? isActive,
    List<String>? amenities,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      workingDays: workingDays ?? this.workingDays,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      totalChairs: totalChairs ?? this.totalChairs,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      amenities: amenities ?? this.amenities,
    );
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    const weekdayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final rawWorkingDays = json['workingDays'] as List<dynamic>?;
    final workingDays = rawWorkingDays == null
        ? const [1, 2, 3, 4, 5, 6, 7]
        : rawWorkingDays
              .map((day) {
                if (day is int) return day;
                return weekdayMap[day.toString()] ?? 0;
              })
              .where((day) => day >= 1 && day <= 7)
              .toList();

    double? lat;
    double? lng;
    final location = json['location'];
    if (location is Map) {
      final coordinates = location['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        lng = (coordinates[0] as num?)?.toDouble();
        lat = (coordinates[1] as num?)?.toDouble();
      }
    }

    final rawDist = json['distanceKm'] ?? json['distance'];
    final double? distanceKm = (rawDist as num?)?.toDouble();

    return BranchModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: [json['address'], json['city']]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toSet()
          .join(', '),
      phone: json['phone'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      workingDays: workingDays,
      openingTime: json['openingTime'] as String? ?? '09:00',
      closingTime: json['closingTime'] as String? ?? '21:00',
      totalChairs: (json['totalChairs'] as num?)?.toInt() ?? 10,
      distanceKm: distanceKm,
      latitude: lat,
      longitude: lng,
      isActive: json['isActive'] as bool? ?? true,
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const ['AC', 'Free Wi-Fi', 'Beverages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'code': code,
      'city': city,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'workingDays': workingDays,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'totalChairs': totalChairs,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (latitude != null && longitude != null)
        'location': {
          'type': 'Point',
          'coordinates': [longitude, latitude],
        },
      'isActive': isActive,
      'amenities': amenities,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
