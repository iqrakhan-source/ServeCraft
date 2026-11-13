class RegisterCustomerRequest {
  final String email;
  final String password;
  final String? confirmPassword;
  final String? name;
  final String? phone;
  final String? gender;
  final String? dob;

  const RegisterCustomerRequest({
    required this.email,
    required this.password,
    this.confirmPassword,
    this.name,
    this.phone,
    this.gender,
    this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (confirmPassword != null && confirmPassword!.isNotEmpty)
        'confirmPassword': confirmPassword,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
    };
  }
}
