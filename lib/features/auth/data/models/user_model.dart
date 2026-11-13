class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final String? gender;
  final String? dateOfBirth;
  final int? age;
  final String role;
  final bool isProfileComplete;
  final List<String> missingFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.role = 'customer',
    required this.isProfileComplete,
    this.missingFields = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    String? gender,
    String? dateOfBirth,
    int? age,
    String? role,
    bool? isProfileComplete,
    List<String>? missingFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      missingFields: missingFields ?? this.missingFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final explicitComplete =
        json['isProfileComplete'] ?? json['is_profile_complete'];
    final name = json['name'] as String? ?? '';

    final bool isProfileComplete;
    if (explicitComplete is bool) {
      isProfileComplete = explicitComplete;
    } else {
      isProfileComplete = name.trim().length >= 2;
    }

    final rawMissing = json['missingFields'];
    final missingFields = rawMissing is List
        ? rawMissing.map((e) => e.toString()).toList()
        : <String>[];

    final rawAge = json['age'];
    final int? age = rawAge is num
        ? rawAge.toInt()
        : int.tryParse(rawAge?.toString() ?? '');

    return UserModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: name,
      phone: (json['phone'] ?? json['mobileNumber'] ?? '') as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: (json['profilePhoto'] ?? json['profileImage']) as String?,
      gender: json['gender'] as String?,
      dateOfBirth: (json['dob'] ?? json['dateOfBirth']) as String?,
      age: age,
      role: (json['role'] ?? 'customer').toString(),
      isProfileComplete: isProfileComplete,
      missingFields: missingFields,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'mobileNumber': phone,
      'email': email,
      'profilePhoto': profileImage,
      'profileImage': profileImage,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'dob': dateOfBirth,
      'age': age,
      'role': role,
      'isProfileComplete': isProfileComplete,
      'missingFields': missingFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.profileImage == profileImage &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.isProfileComplete == isProfileComplete;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    email,
    profileImage,
    gender,
    dateOfBirth,
    isProfileComplete,
  );
}
