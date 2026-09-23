import 'user_model.dart';

class VerifyOtpResponse {
  final String token;
  final String? refreshToken;
  final UserModel user;
  final bool isNewUser;

  const VerifyOtpResponse({
    required this.token,
    this.refreshToken,
    required this.user,
    this.isNewUser = false,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : UserModel(
              id: '',
              name: '',
              phone: '',
              email: '',
              isProfileComplete: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'isNewUser': isNewUser,
    };
  }
}
