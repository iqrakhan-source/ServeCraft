class LoginRequest {
  final String? phone;
  final String? email;
  final String password;

  LoginRequest({this.phone, this.email, required this.password})
    : assert(
        (phone != null && phone.isNotEmpty) ||
            (email != null && email.isNotEmpty),
        'Phone or email is required',
      );

  Map<String, dynamic> toJson() {
    return {
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      'password': password,
    };
  }
}
