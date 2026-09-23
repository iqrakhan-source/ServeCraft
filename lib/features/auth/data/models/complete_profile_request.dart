class CompleteProfileRequest {
  final String name;
  final String? email;
  final String? profileImage;

  const CompleteProfileRequest({
    required this.name,
    this.email,
    this.profileImage,
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
    return map;
  }
}
