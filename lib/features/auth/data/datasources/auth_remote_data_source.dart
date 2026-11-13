import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/aesthetic_preferences_request.dart';
import '../models/change_password_request.dart';
import '../models/complete_profile_request.dart';
import '../models/forgot_password_request.dart';
import '../models/password_reset_response.dart';
import '../models/reset_password_request.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../models/register_customer_request.dart';
import '../models/register_customer_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterCustomerResponse> registerCustomer(
    RegisterCustomerRequest request,
  );

  Future<LoginResponse> login(String identifier, String password);

  Future<Map<String, dynamic>> refreshToken(String refreshToken);

  Future<PasswordResetResponse> forgotPassword(ForgotPasswordRequest request);

  Future<PasswordResetResponse> resetPassword(ResetPasswordRequest request);

  Future<bool> changePassword(ChangePasswordRequest request);

  Future<UserModel> getCurrentUser();

  Future<UserModel> completeProfile(CompleteProfileRequest request);

  Future<UserModel> updateProfile(Map<String, dynamic> data);

  Future<String> uploadProfilePhoto(dynamic fileOrPath);

  Future<bool> registerFcmToken(String fcmToken);

  Future<bool> updateAestheticPreferences(
    AestheticPreferencesRequest preferences,
  );

  Future<SendOtpResponse> sendOtp(SendOtpRequest request);
  Future<SendOtpResponse> sendSignupOtp(String email);
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request);

  Future<void> logout();
}

/// Production implementation connecting to REST backend via ApiService
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiService;
  final StorageService storageService;

  AuthRemoteDataSourceImpl({
    required this.apiService,
    required this.storageService,
  });

  @override
  Future<RegisterCustomerResponse> registerCustomer(
    RegisterCustomerRequest request,
  ) async {
    developer.log(
      '🚀 [AuthRemoteDataSource] Dispatching customer registration to ${ApiConstants.registerCustomer}',
      name: 'AuthRemoteDataSource',
    );

    final response = await apiService.post<RegisterCustomerResponse>(
      ApiConstants.registerCustomer,
      data: request.toJson(),
      fromJson: (json) => RegisterCustomerResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    if (response.data == null) {
      throw ServerException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Customer registration failed',
      );
    }

    return response.data!;
  }

  @override
  Future<LoginResponse> login(String identifier, String password) async {
    final value = identifier.trim();

    if (value.isEmpty || password.isEmpty) {
      throw const BadRequestException(
        message: 'Phone number or email and password are required',
      );
    }

    final request = value.contains('@')
        ? LoginRequest(email: value, password: password)
        : LoginRequest(phone: value, password: password);

    developer.log(
      '[AuthRemoteDataSource] Login request started for $value',
      name: 'AuthRemoteDataSource',
    );

    final response = await apiService.post<LoginResponse>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: (json) =>
          LoginResponse.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    if (response.data == null) {
      throw ServerException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Login failed',
      );
    }

    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (response.data == null) {
      throw const ServerException(message: 'Failed to refresh token');
    }

    return response.data!;
  }

  @override
  Future<PasswordResetResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    final response = await apiService.post<PasswordResetResponse>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return PasswordResetResponse.fromJson(json);
        }
        return const PasswordResetResponse(success: true, message: '');
      },
    );

    if (response.data != null && response.data!.success) {
      return response.data!;
    }

    if (response.success) {
      return PasswordResetResponse(
        success: true,
        message: response.message.isNotEmpty
            ? response.message
            : 'If an account exists with that email address, password reset instructions have been sent.',
      );
    }

    throw ServerException(
      message: response.message.isNotEmpty
          ? response.message
          : 'Failed to request password reset',
    );
  }

  @override
  Future<PasswordResetResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final response = await apiService.post<PasswordResetResponse>(
      ApiConstants.resetPassword,
      data: request.toJson(),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return PasswordResetResponse.fromJson(json);
        }
        return const PasswordResetResponse(success: true, message: '');
      },
    );

    if (response.data != null && response.data!.success) {
      await storageService.remove(StorageKeys.resetToken);
      return response.data!;
    }

    if (response.success) {
      await storageService.remove(StorageKeys.resetToken);
      return PasswordResetResponse(
        success: true,
        message: response.message.isNotEmpty
            ? response.message
            : 'Password has been reset successfully. Please log in.',
      );
    }

    throw ServerException(
      message: response.message.isNotEmpty
          ? response.message
          : 'Failed to reset password',
    );
  }

  @override
  Future<bool> changePassword(ChangePasswordRequest request) async {
    final response = await apiService.put<Map<String, dynamic>>(
      ApiConstants.changePassword,
      data: request.toJson(),
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    return response.success;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiService.get<UserModel>(
      ApiConstants.profile,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final userMap = json['customer'] ?? json['user'] ?? json['data'];
          if (userMap is Map<String, dynamic>) {
            final complete = json['isProfileComplete'] as bool?;
            final missing = json['missingFields'] as List<dynamic>?;
            final user = UserModel.fromJson(userMap);
            return user.copyWith(
              isProfileComplete: complete ?? user.isProfileComplete,
              missingFields: missing?.map((e) => e.toString()).toList(),
            );
          }
          return UserModel.fromJson(json);
        }
        return UserModel.fromJson(const {});
      },
    );

    if (response.data == null) {
      throw const NotFoundException(message: 'User profile not found');
    }

    return response.data!;
  }

  @override
  Future<UserModel> completeProfile(CompleteProfileRequest request) async {
    final response = await apiService.patch<UserModel>(
      ApiConstants.updateProfile,
      data: request.toJson(),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final userMap = json['user'] ?? json['customer'] ?? json['data'];
          if (userMap is Map<String, dynamic>) {
            return UserModel.fromJson(userMap);
          }
          return UserModel.fromJson(json);
        }
        return UserModel.fromJson(const {});
      },
    );

    if (response.data == null) {
      throw const ServerException(message: 'Failed to complete profile');
    }

    return response.data!;
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await apiService.patch<UserModel>(
      ApiConstants.updateProfile,
      data: data,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final userMap = json['user'] ?? json['customer'] ?? json['data'];
          if (userMap is Map<String, dynamic>) {
            return UserModel.fromJson(userMap);
          }
          return UserModel.fromJson(json);
        }
        return UserModel.fromJson(const {});
      },
    );

    if (response.data == null) {
      throw const ServerException(message: 'Failed to update profile');
    }

    return response.data!;
  }

  @override
  Future<String> uploadProfilePhoto(dynamic fileOrPath) async {
    FormData formData;

    if (fileOrPath is File) {
      final fileName = fileOrPath.path.split('/').last.split('\\').last;
      formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          fileOrPath.path,
          filename: fileName,
        ),
      });
    } else if (fileOrPath is String) {
      if (fileOrPath.startsWith('http') || fileOrPath.startsWith('data:')) {
        // Already a remote URL or base64 data string
        return fileOrPath;
      }
      final fileName = fileOrPath.split('/').last.split('\\').last;
      formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(fileOrPath, filename: fileName),
      });
    } else {
      throw const BadRequestException(message: 'Invalid photo file or path');
    }

    final response = await apiService.postMultipart<String>(
      ApiConstants.profilePhoto,
      formData: formData,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return (json['profilePhoto'] ??
                  json['photo'] ??
                  json['imageUrl'] ??
                  '')
              .toString();
        }
        return json.toString();
      },
    );

    return response.data ?? '';
  }

  @override
  Future<bool> registerFcmToken(String fcmToken) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.fcmToken,
      data: {'fcmToken': fcmToken},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    return response.success;
  }

  @override
  Future<bool> updateAestheticPreferences(
    AestheticPreferencesRequest preferences,
  ) async {
    final response = await apiService.patch<Map<String, dynamic>>(
      ApiConstants.preferences,
      data: preferences.toJson(),
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    return response.success;
  }

  @override
  Future<SendOtpResponse> sendSignupOtp(String email) async {
    final response = await apiService.post<SendOtpResponse>(
      ApiConstants.signupSendOtp,
      data: {'email': email},
      fromJson: (json) => SendOtpResponse.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );
    if (response.data == null) {
      return SendOtpResponse(
        success: response.success,
        message: response.message.isNotEmpty
            ? response.message
            : 'OTP sent successfully',
      );
    }
    return response.data!;
  }

  @override
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final response = await apiService.post<SendOtpResponse>(
      ApiConstants.sendOtp,
      data: request.toJson(),
      fromJson: (json) =>
          SendOtpResponse.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to send OTP');
    }
    return response.data!;
  }

  @override
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await apiService.post<VerifyOtpResponse>(
      ApiConstants.verifyOtp,
      data: request.toJson(),
      fromJson: (json) =>
          VerifyOtpResponse.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to verify OTP');
    }
    return response.data!;
  }

  @override
  Future<void> logout() async {
    try {
      await apiService.post(ApiConstants.logout);
    } catch (_) {}
  }
}
