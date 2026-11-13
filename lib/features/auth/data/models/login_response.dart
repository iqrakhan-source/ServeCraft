import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final bool isProfileComplete;
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  final String token;

  const LoginResponse({
    this.success = true,
    this.message = '',
    this.isProfileComplete = true,
    required this.accessToken,
    this.refreshToken,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // API response may contain the actual login data inside "data".
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final accessToken =
        data['accessToken'] ?? data['token'] ?? json['accessToken'];
    final refreshToken = data['refreshToken'] ?? json['refreshToken'];

    final userData =
        data['user'] ??
        data['customer'] ??
        (data.containsKey('email') ? data : null);

    if (json['success'] == false) {
      throw FormatException(json['message']?.toString() ?? 'Login failed.');
    }

    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException(
        'Login response is missing a valid access token.',
      );
    }

    if (userData is! Map) {
      throw const FormatException('Login response is missing user data.');
    }

    final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
    final bool isProfileComplete =
        (json['isProfileComplete'] as bool?) ??
        (data['isProfileComplete'] as bool?) ??
        user.isProfileComplete;

    return LoginResponse(
      success: true,
      message: json['message']?.toString() ?? 'Login successful.',
      isProfileComplete: isProfileComplete,
      accessToken: accessToken,
      refreshToken: refreshToken is String ? refreshToken : null,
      user: user.copyWith(isProfileComplete: isProfileComplete),
      token: accessToken,
    );
  }
}
