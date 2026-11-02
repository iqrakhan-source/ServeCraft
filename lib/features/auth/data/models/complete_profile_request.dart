class CompleteProfileRequest {
  final String name;
  final String? email;
  final String? profileImage;
  final String? gender;
  final String? dateOfBirth;

  const CompleteProfileRequest({
    required this.name,
    this.email,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
    };
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (profileImage != null && profileImage!.trim().isNotEmpty) {
      map['profileImage'] = profileImage;
    }
    if (gender != null && gender!.trim().isNotEmpty) {
      map['gender'] = gender!.trim();
    }
    if (dateOfBirth != null && dateOfBirth!.trim().isNotEmpty) {
      final dobStr = dateOfBirth!.trim();
      map['dateOfBirth'] = dobStr;
      final parsedDate = DateTime.tryParse(dobStr);
      if (parsedDate != null) {
        final now = DateTime.now();
        var age = now.year - parsedDate.year;
        if (now.month < parsedDate.month ||
            (now.month == parsedDate.month && now.day < parsedDate.day)) {
          age--;
        }
        if (age > 0) {
          map['age'] = age;
        }
      }
    }
    return map;
  }
}
