
import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  final String token;

  const LoginResponse({
    this.success = true,
    this.message = '',
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

    final accessToken = data['accessToken'] ?? data['token'];
    final refreshToken = data['refreshToken'];

    final userData = data['user'] ?? data['customer'];

    if (json['success'] == false) {
      throw FormatException(
        json['message']?.toString() ?? 'Login failed.',
      );
    }

    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException(
        'Login response is missing a valid access token.',
      );
    }

    if (userData is! Map) {
      throw const FormatException(
        'Login response is missing user data.',
      );
    }

    return LoginResponse(
      success: true,
      message: json['message']?.toString() ?? 'Login successful.',
      accessToken: accessToken,
      refreshToken: refreshToken is String ? refreshToken : null,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(userData),
      ),
      // Keep compatibility with existing code that reads "token".
      token: accessToken,
    );
  }
}
