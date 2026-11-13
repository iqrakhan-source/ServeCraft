import 'package:prop_crm/features/auth/data/models/aesthetic_preferences_request.dart';
import 'package:prop_crm/features/auth/data/models/change_password_request.dart';
import 'package:prop_crm/features/auth/data/models/forgot_password_request.dart';
import 'package:prop_crm/features/auth/data/models/login_response.dart';
import 'package:prop_crm/features/auth/data/models/password_reset_response.dart';
import 'package:prop_crm/features/auth/data/models/register_customer_request.dart';
import 'package:prop_crm/features/auth/data/models/register_customer_response.dart';
import 'package:prop_crm/features/auth/data/models/reset_password_request.dart';
import 'package:prop_crm/features/auth/data/models/send_otp_response.dart';
import 'package:prop_crm/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<RegisterCustomerResponse> registerCustomer(
    RegisterCustomerRequest request,
  );

  Future<LoginResponse> login(String identifier, String password);

  Future<bool> refreshToken();

  Future<PasswordResetResponse> forgotPassword(ForgotPasswordRequest request);

  Future<PasswordResetResponse> resetPassword(ResetPasswordRequest request);

  Future<bool> changePassword(ChangePasswordRequest request);

  Future<UserModel> completeProfile({
    required String name,
    String? phone,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  });

  Future<UserModel> updateProfile(Map<String, dynamic> data);

  Future<String> uploadProfilePhoto(dynamic fileOrPath);

  Future<bool> registerFcmToken(String fcmToken);

  Future<bool> updateAestheticPreferences(
    AestheticPreferencesRequest preferences,
  );

  Future<SendOtpResponse> sendOtp(String phone);

  Future<UserModel?> checkAuthSession();

  Future<UserModel?> getCachedUser();

  Future<void> logout();
}
