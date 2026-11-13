class CompleteProfileRequest {
  final String name;
  final String? phone;
  final String? email;
  final String? gender;
  final String? dateOfBirth;
  final String? profileImage;

  const CompleteProfileRequest({
    required this.name,
    this.phone,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dateOfBirth != null && dateOfBirth!.isNotEmpty) ...{
        'dob': dateOfBirth,
        'dateOfBirth': dateOfBirth,
      },
      if (profileImage != null && profileImage!.isNotEmpty)
        'profilePhoto': profileImage,
    };
  }
}
