import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/complete_profile_request.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<SendOtpResponse> sendOtp(SendOtpRequest request);
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request);
  Future<UserModel> completeProfile(CompleteProfileRequest request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

/// Production implementation connecting to REST backend via ApiService
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final response = await apiService.post<SendOtpResponse>(
      ApiConstants.sendOtp,
      data: request.toJson(),
      fromJson: (json) => SendOtpResponse.fromJson(json as Map<String, dynamic>),
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
    final response = await apiService.post<UserModel>(
      ApiConstants.completeProfile,
      data: request.toJson(),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to complete profile');
    }
    return response.data!;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiService.get<UserModel>(
      ApiConstants.profile,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
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
}

/// TEMPORARY: Isolated mock data source for Phase 2 development prior to backend deployment.
/// Simulates realistic network latency, validation, and supports testing both:
/// 1. Existing user flow (phone ending with '99' -> isProfileComplete: true)
/// 2. New user flow (other phones -> isProfileComplete: false)
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? _mockCurrentUser;

  @override
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (request.phone.length != 10) {
      throw const BadRequestException(message: 'Invalid phone number format');
    }

    return SendOtpResponse(
      success: true,
      message: 'OTP sent successfully to +91 ${request.phone}',
      expiresInSeconds: 30,
      resendToken: 'mock_resend_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (request.otp.length != 6) {
      throw const BadRequestException(message: 'Invalid OTP length');
    }

    // In mock mode, any 6-digit OTP is accepted (or reject '000000' for error testing)
    if (request.otp == '000000') {
      throw const BadRequestException(message: 'Incorrect OTP. Please try again.');
    }

    // Check if phone represents an existing user (convention: ending in '99')
    final isExistingUser = request.phone.endsWith('99');

    final user = isExistingUser
        ? UserModel(
            id: 'usr_${request.phone}',
            name: 'Alex Morgan',
            phone: request.phone,
            email: 'alex.morgan@example.com',
            profileImage: null,
            isProfileComplete: true,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          )
        : UserModel(
            id: 'usr_${request.phone}',
            name: '',
            phone: request.phone,
            email: '',
            profileImage: null,
            isProfileComplete: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    _mockCurrentUser = user;

    return VerifyOtpResponse(
      token: 'mock_jwt_token_${request.phone}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${request.phone}',
      user: user,
      isNewUser: !isExistingUser,
    );
  }

  @override
  Future<UserModel> completeProfile(CompleteProfileRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (request.name.trim().length < 2) {
      throw const ValidationException(
        message: 'Name must be at least 2 characters',
        fieldErrors: {
          'name': ['Name must be at least 2 characters']
        },
      );
    }

    final current = _mockCurrentUser ??
        UserModel(
          id: 'usr_mock_123',
          name: '',
          phone: '9876543210',
          email: '',
          isProfileComplete: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = current.copyWith(
      name: request.name.trim(),
      email: request.email?.trim(),
      profileImage: request.profileImage,
      isProfileComplete: true,
      updatedAt: DateTime.now(),
    );

    _mockCurrentUser = updated;
    return updated;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_mockCurrentUser == null) {
      throw const UnauthorizedException(message: 'User is not logged in');
    }
    return _mockCurrentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCurrentUser = null;
  }
}
