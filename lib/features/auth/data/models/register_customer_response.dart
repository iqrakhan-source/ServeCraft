
class RegisterCustomerResponse {
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> user;

  const RegisterCustomerResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory RegisterCustomerResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final accessToken = json['accessToken'] ?? json['token'];
    final userData = json['user'] ?? json['customer'] ?? json['data'];

    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException(
        'Registration response is missing a valid accessToken or token.',
      );
    }

    if (userData is! Map) {
      throw const FormatException(
        'Registration response is missing valid user data.',
      );
    }

    final refreshToken = json['refreshToken'];

    return RegisterCustomerResponse(
      accessToken: accessToken,
      refreshToken:
      refreshToken is String ? refreshToken : null,
      user: Map<String, dynamic>.from(userData),
    );
  }
}
