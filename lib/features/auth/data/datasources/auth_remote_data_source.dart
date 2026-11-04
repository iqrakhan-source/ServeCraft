import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_service.dart';
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

  Future<LoginResponse> login(String email, String password);

  Future<PasswordResetResponse> forgotPassword(ForgotPasswordRequest request);

  Future<PasswordResetResponse> resetPassword(ResetPasswordRequest request);

  Future<SendOtpResponse> sendOtp(SendOtpRequest request);
  Future<SendOtpResponse> sendSignupOtp(String email);
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request);

  Future<UserModel> completeProfile(CompleteProfileRequest request);
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> updateClinicalPreferences(Map<String, dynamic> preferences);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

/// Production implementation connecting to REST backend via ApiService
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiService;
  final StorageService storageService;


  AuthRemoteDataSourceImpl(
      {required this.apiService, required this.storageService,
      });

  //get body => null;

  @override
  Future<RegisterCustomerResponse> registerCustomer(
      RegisterCustomerRequest request,) async {
    developer.log(
      '🚀 [AuthRemoteDataSource] Dispatching customer registration to ${ApiConstants
          .registerCustomer} '
          '(name: ${request.name}, email: ${request.email}, phone: ${request
          .phone}, gender: ${request.gender})',
      name: 'AuthRemoteDataSource',
    );

    final response = await apiService.post<RegisterCustomerResponse>(
      ApiConstants.registerCustomer,
      data: request.toJson(),
      fromJson: (json) =>
          RegisterCustomerResponse.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
    );

    developer.log(
      '📥 [AuthRemoteDataSource] Registration response received '
          '(success: ${response.success}, statusCode: ${response.statusCode})',
      name: 'AuthRemoteDataSource',
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
  Future<PasswordResetResponse> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    final response = await apiService.post<PasswordResetResponse>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
      fromJson: (json) => PasswordResetResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final result = response.data;

    if (result != null && result.success) {
      final token = result.resetToken;

      if (token != null && token.isNotEmpty) {
        final saved = await storageService.setString(
          StorageKeys.resetToken,
          token,
        );

        if (!saved) {
          throw const ServerException(
            message: 'Password reset token could not be stored.',
          );
        }
      }

      return result;
    }

    if (response.success) {
      return PasswordResetResponse(
        success: true,
        message: response.message,
      );
    }
    if (response.data != null && response.data!.success) {
      final token = response.data!.resetToken;

      if (token != null && token.isNotEmpty) {
        final saved = await storageService.setString(
          StorageKeys.resetToken,
          token,
        );

        debugPrint('Reset token saved: $saved');
      } else {
        debugPrint('Reset token was not present in parsed response');
      }

      return response.data!;
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
      fromJson: (json) => PasswordResetResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    if (response.data != null && response.data!.success) {
      // Clear the token only after a successful password reset.
      await storageService.remove(StorageKeys.resetToken);
      return response.data!;
    }

    if (response.success) {
      await storageService.remove(StorageKeys.resetToken);

      return PasswordResetResponse(
        success: true,
        message: response.message,
      );
    }

    throw ServerException(
      message: response.message.isNotEmpty
          ? response.message
          : 'Failed to reset password',
    );
  }


  @override
  Future<SendOtpResponse> sendSignupOtp(String email) async {
    final response = await apiService.post<SendOtpResponse>(
      ApiConstants.signupSendOtp,
      data: {'email': email},
      fromJson: (json) =>
          SendOtpResponse.fromJson(
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
  Future<UserModel> updateClinicalPreferences(
      Map<String, dynamic> preferences,) async {
    final response = await apiService.patch<UserModel>(
      ApiConstants.clinicalPreferences,
      data: preferences,
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
      throw const ServerException(
        message: 'Failed to update clinical preferences',
      );
    }
    return response.data!;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiService.get<UserModel>(
      ApiConstants.profile,
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
      throw const NotFoundException(message: 'User profile not found');
    }
    return response.data!;
  }

  @override
  Future<void> logout() async {
    await apiService.post(ApiConstants.logout);
  }

  @override
  Future<LoginResponse> login(String identifier, String password) async {
    final value = identifier.trim();

    if (value.isEmpty || password.isEmpty) {
      throw const BadRequestException(
        message: 'Phone number/email and password are required',
      );
    }

    final request = value.contains('@')
        ? LoginRequest(email: value, password: password)
        : LoginRequest(phone: value, password: password);

    developer.log(
      '[AuthRemoteDataSource] Login request started',
      name: 'AuthRemoteDataSource',
    );

    final response = await apiService.post<LoginResponse>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: (json) =>
          LoginResponse.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
    );

    if (response.data == null) {
      throw ServerException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Login failed',
      );
    }

    developer.log(
      '[AuthRemoteDataSource] Login response received',
      name: 'AuthRemoteDataSource',
    );

    return response.data!;
  }


}
/// TEMPORARY: Isolated mock data source for Phase 2 development prior to backend deployment.
/// Simulates realistic network latency, validation, and supports testing both:
/// 1. Existing user flow (phone ending with '99' -> isProfileComplete: true)
/// 2. New user flow (other phones -> isProfileComplete: false)
// class MockAuthRemoteDataSource implements AuthRemoteDataSource {
//   UserModel? _mockCurrentUser;
//
//
  @override
  Future<LoginResponse> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final value = identifier.trim();

    if (value.isEmpty || password.isEmpty) {
      throw const BadRequestException(
        message: 'Phone number/email and password are required',
      );
    }

    final isEmail = value.contains('@');

    if (isEmail &&
        (!value.contains('@') || !value.contains('.'))) {
      throw const BadRequestException(
        message: 'Please enter a valid email address',
      );
    }

    if (!isEmail && !RegExp(r'^\d{10}$').hasMatch(value)) {
      throw const BadRequestException(
        message: 'Please enter a valid 10-digit phone number',
      );
    }

    // Temporary mock: this does not verify real credentials.
    // Return a LoginResponse here using your model's constructor.
    throw UnimplementedError(
      'LoginResponse construction still needs to be added',
    );
  }

//   @override
//   Future<RegisterCustomerResponse> registerCustomer(
//     RegisterCustomerRequest request,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//
//     if (request.name.trim().length < 2) {
//       throw const BadRequestException(message: 'Please enter a valid name');
//     }
//
//     if (!request.email.contains('@')) {
//       throw const BadRequestException(message: 'Please enter a valid email');
//     }
//
//     if (request.phone.length != 10) {
//       throw const BadRequestException(
//         message: 'Please enter a valid phone number',
//       );
//     }
//
//     if (request.password != request.confirmPassword) {
//       throw const BadRequestException(message: 'Passwords do not match');
//     }
//
//     final userId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
//
//     return RegisterCustomerResponse(
//       accessToken: 'mock_access_token_$userId',
//       refreshToken: 'mock_refresh_token_$userId',
//       user: {
//         'id': userId,
//         'name': request.name.trim(),
//         'email': request.email.trim(),
//         'phone': request.phone,
//         'gender': request.gender,
//       },
//     );
//   }
//
//   @override
//   Future<PasswordResetResponse> forgotPassword(
//     ForgotPasswordRequest request,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final email = request.email.trim();
//
//     if (email.isEmpty || !email.contains('@')) {
//       throw const BadRequestException(
//         message: 'Please enter a valid email address',
//       );
//     }
//
//     // Development mock response.
//     return PasswordResetResponse(
//       success: true,
//       message:
//           'If an account exists with that email address, '
//           'password reset instructions have been sent.',
//       resetToken: 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}',
//     );
//   }
//
//   @override
//   Future<PasswordResetResponse> resetPassword(
//     ResetPasswordRequest request,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     if (request.resetToken.trim().isEmpty) {
//       throw const BadRequestException(message: 'Reset token is required');
//     }
//
//     if (request.newPassword.length < 8) {
//       throw const BadRequestException(
//         message: 'Password must be at least 8 characters',
//       );
//     }
//
//     return const PasswordResetResponse(
//       success: true,
//       message: 'Password has been reset successfully. Please log in.',
//     );
//   }
//
//   @override
//   Future<SendOtpResponse> sendSignupOtp(String email) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//
//     final trimmedEmail = email.trim().toLowerCase();
//     if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
//       throw const BadRequestException(message: 'Invalid email address');
//     }
//
//     if (trimmedEmail == 'registered@example.com' ||
//         trimmedEmail == 'existing@example.com') {
//       throw const ConflictException(
//         message: 'This email is already registered. Please sign in.',
//       );
//     }
//
//     return SendOtpResponse(
//       success: true,
//       message: 'Verification code sent to $email',
//       expiresInSeconds: 30,
//       resendToken: 'mock_resend_token_${DateTime.now().millisecondsSinceEpoch}',
//     );
//   }
//
//   @override
//   Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//
//     if (request.phone.length != 10) {
//       throw const BadRequestException(message: 'Invalid phone number format');
//     }
//
//     return SendOtpResponse(
//       success: true,
//       message: 'OTP sent successfully to +91 ${request.phone}',
//       expiresInSeconds: 30,
//       resendToken: 'mock_resend_token_${DateTime.now().millisecondsSinceEpoch}',
//     );
//   }
//
//   @override
//   Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
//     await Future.delayed(const Duration(milliseconds: 700));
//
//     if (request.otp.length != 6) {
//       throw const BadRequestException(message: 'Invalid OTP length');
//     }
//
//     // In mock mode, any 6-digit OTP is accepted (or reject '000000' for error testing)
//     if (request.otp == '000000') {
//       throw const BadRequestException(
//         message: 'Incorrect OTP. Please try again.',
//       );
//     }
//
//     // Check if phone represents an existing user (convention: ending in '99')
//     final isExistingUser = request.phone.endsWith('99');
//
//     final user = isExistingUser
//         ? UserModel(
//             id: 'usr_${request.phone}',
//             name: 'Alex Morgan',
//             phone: request.phone,
//             email: 'alex.morgan@example.com',
//             profileImage: null,
//             isProfileComplete: true,
//             createdAt: DateTime.now().subtract(const Duration(days: 30)),
//             updatedAt: DateTime.now(),
//           )
//         : UserModel(
//             id: 'usr_${request.phone}',
//             name: '',
//             phone: request.phone,
//             email: '',
//             profileImage: null,
//             isProfileComplete: false,
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//           );
//
//     _mockCurrentUser = user;
//
//     return VerifyOtpResponse(
//       token:
//           'mock_jwt_token_${request.phone}_${DateTime.now().millisecondsSinceEpoch}',
//       refreshToken: 'mock_refresh_token_${request.phone}',
//       user: user,
//       isNewUser: !isExistingUser,
//     );
//   }
//
//   @override
//   Future<UserModel> completeProfile(CompleteProfileRequest request) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//
//     if (request.name.trim().length < 2) {
//       throw const ValidationException(
//         message: 'Name must be at least 2 characters',
//         fieldErrors: {
//           'name': ['Name must be at least 2 characters'],
//         },
//       );
//     }
//
//     final current =
//         _mockCurrentUser ??
//         UserModel(
//           id: 'usr_mock_123',
//           name: '',
//           phone: '9876543210',
//           email: '',
//           isProfileComplete: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//
//     final updated = current.copyWith(
//       name: request.name.trim(),
//       email: request.email?.trim(),
//       gender: request.gender?.trim(),
//       dateOfBirth: request.dateOfBirth?.trim(),
//       profileImage: request.profileImage,
//       isProfileComplete: true,
//       updatedAt: DateTime.now(),
//     );
//
//     _mockCurrentUser = updated;
//     return updated;
//   }
//
//   @override
//   Future<UserModel> updateProfile(Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     final current =
//         _mockCurrentUser ??
//         UserModel(
//           id: 'usr_mock_123',
//           name: '',
//           phone: '9876543210',
//           email: '',
//           isProfileComplete: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//
//     final updated = current.copyWith(
//       name: data['name'] as String? ?? current.name,
//       email: data['email'] as String? ?? current.email,
//       gender: data['gender'] as String? ?? current.gender,
//       dateOfBirth: data['dateOfBirth'] as String? ?? current.dateOfBirth,
//       profileImage: data['profileImage'] as String? ?? current.profileImage,
//       isProfileComplete: true,
//       updatedAt: DateTime.now(),
//     );
//
//     _mockCurrentUser = updated;
//     return updated;
//   }
//
//   @override
//   Future<UserModel> updateClinicalPreferences(
//     Map<String, dynamic> preferences,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _mockCurrentUser ??
//         UserModel(
//           id: 'usr_mock_123',
//           name: '',
//           phone: '9876543210',
//           email: '',
//           isProfileComplete: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//   }
//
//   @override
//   Future<UserModel> getCurrentUser() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     if (_mockCurrentUser == null) {
//       throw const UnauthorizedException(message: 'User is not logged in');
//     }
//     return _mockCurrentUser!;
//   }
//
//   @override
//   Future<void> logout() async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _mockCurrentUser = null;
//   }
//
//
// }
