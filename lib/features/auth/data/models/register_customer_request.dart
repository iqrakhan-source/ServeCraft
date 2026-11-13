class RegisterCustomerRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String gender;
  final String dob;

  const RegisterCustomerRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.gender,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
      'gender': gender,
      'dob': dob,
    };
  }
}
