
import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const LoginResponse({
    this.success = true,
    this.message = '',
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] ?? json['token'];
    final refreshToken = json['refreshToken'];

    final userData = json['user'] ??
        json['customer'] ??
        (json['data'] is Map ? json['data']['user'] : null) ??
        json['data'];

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
      success: json['success'] is bool ? json['success'] as bool : true,
      message: json['message']?.toString() ?? '',
      accessToken: accessToken,
      refreshToken: refreshToken is String ? refreshToken : null,
      user: UserModel.fromJson(Map<String, dynamic>.from(userData)),
    );
  }
}

