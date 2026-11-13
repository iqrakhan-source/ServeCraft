class StylistModel {
  final String id;
  final String name;
  final String role;
  final List<String> specializations;
  final double rating;
  final String? imageUrl;
  final bool isAvailable;

  const StylistModel({
    required this.id,
    required this.name,
    this.role = 'Stylist',
    this.specializations = const [],
    this.rating = 5.0,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specializations'];
    final specs = rawSpecs is List
        ? rawSpecs.map((e) => e.toString()).toList()
        : <String>[];

    final workPics = json['workPic'];
    String? img;
    if (json['profileImage'] != null &&
        json['profileImage'].toString().isNotEmpty) {
      img = json['profileImage'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      img = json['image'].toString();
    } else if (workPics is List && workPics.isNotEmpty) {
      img = workPics.first.toString();
    }

    final rawRole = (json['role'] ?? 'Stylist').toString();
    final formattedRole = rawRole
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');

    return StylistModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Stylist').toString(),
      role: formattedRole,
      specializations: specs,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      imageUrl: img,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'role': role,
      'specializations': specializations,
      'rating': rating,
      'profileImage': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  static const StylistModel anyStylist = StylistModel(
    id: 'any',
    name: 'Any Available Stylist',
    role: 'First Available',
    specializations: ['Fastest Booking'],
    rating: 5.0,
    isAvailable: true,
  );
}
