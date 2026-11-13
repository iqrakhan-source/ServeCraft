import 'user_model.dart';

class RegisterCustomerResponse {
  final bool success;
  final String message;
  final bool isProfileComplete;
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> user;
  final UserModel? userModel;

  const RegisterCustomerResponse({
    this.success = true,
    this.message = 'Account registered successfully',
    this.isProfileComplete = false,
    required this.accessToken,
    this.refreshToken,
    required this.user,
    this.userModel,
  });

  factory RegisterCustomerResponse.fromJson(Map<String, dynamic> json) {
    // If ApiClient parsed the "data" sub-object into json:
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final accessToken =
        data['accessToken'] ?? data['token'] ?? json['accessToken'];
    final userData =
        data['user'] ??
        data['customer'] ??
        (data.containsKey('email') ? data : null);

    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException(
        'Registration response is missing a valid accessToken.',
      );
    }

    final userMap = userData is Map
        ? Map<String, dynamic>.from(userData)
        : <String, dynamic>{};

    final bool isProfileComplete =
        (json['isProfileComplete'] as bool?) ??
        (userMap['isProfileComplete'] as bool?) ??
        false;

    return RegisterCustomerResponse(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? 'Account registered successfully',
      isProfileComplete: isProfileComplete,
      accessToken: accessToken,
      refreshToken: (data['refreshToken'] ?? json['refreshToken']) as String?,
      user: userMap,
      userModel: userMap.isNotEmpty ? UserModel.fromJson(userMap) : null,
    );
  }
}
