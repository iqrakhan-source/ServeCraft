import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/storage/storage_keys.dart';
import 'package:prop_crm/core/storage/storage_service.dart';
import '../../../../core/networking/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/complete_profile_request.dart';
import '../models/register_customer_request.dart';
import '../models/register_customer_response.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../../data/models/login_response.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/password_reset_response.dart';
import '../../data/models/reset_password_request.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);

    // Stop if login was unsuccessful.
    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Login failed. Please check your credentials.',
      );
    }

    // Save the access token.
    final token = response.accessToken.isNotEmpty
        ? response.accessToken
        : response.token;

    if (token.isNotEmpty) {
      await storageService.setString(
        StorageKeys.authToken,
        token,
      );
    }

    // Save refresh token if provided.
    if (response.refreshToken != null &&
        response.refreshToken!.isNotEmpty) {
      await storageService.setString(
        StorageKeys.refreshToken,
        response.refreshToken!,
      );
    }

    // Save user details.
    await storageService.setString(
      StorageKeys.userId,
      response.user.id,
    );

    if (response.user.phone.isNotEmpty) {
      await storageService.setString(
        StorageKeys.userPhone,
        response.user.phone,
      );
    }

    await storageService.setBool(
      StorageKeys.isProfileComplete,
      response.user.isProfileComplete,
    );

    await _saveUserToCache(response.user);

    return response;
  }

  @override
  Future<RegisterCustomerResponse> registerCustomer(
      RegisterCustomerRequest request,
      ) async {
    debugPrint('REGISTER [AuthRepository]: Repository method reached for ${request.email}');

    try {
      debugPrint('REGISTER [AuthRepository]: Calling remote data source');

      final response =
      await remoteDataSource.registerCustomer(request);

      debugPrint('REGISTER [AuthRepository]: Remote data source returned successfully');
      debugPrint('REGISTER [AuthRepository]: Access token received: '
          '${response.accessToken.isNotEmpty}');
      debugPrint('REGISTER [AuthRepository]: User data received: ${response.user.isNotEmpty}');

      await storageService.setString(
        StorageKeys.authToken,
        response.accessToken,
      );

      if (response.refreshToken != null &&
          response.refreshToken!.isNotEmpty) {
        await storageService.setString(
          StorageKeys.refreshToken,
          response.refreshToken!,
        );
      }

      final userId =
          (response.user['id'] ?? response.user['_id'])?.toString();
      final phone = response.user['phone']?.toString();

      if (userId != null && userId.isNotEmpty) {
        await storageService.setString(StorageKeys.userId, userId);
      }

      if (phone != null && phone.isNotEmpty) {
        await storageService.setString(StorageKeys.userPhone, phone);
      }

      await storageService.setBool(
        StorageKeys.isProfileComplete,
        false,
      );

      debugPrint('REGISTER [AuthRepository]: Token storage completed successfully');
      return response;
    } catch (e, stackTrace) {
      debugPrint('REGISTER [AuthRepository] ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<PasswordResetResponse> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    return await remoteDataSource.forgotPassword(request);
  }

  @override
  Future<PasswordResetResponse> resetPassword(
      ResetPasswordRequest request,
      ) async {
    return await remoteDataSource.resetPassword(request);
  }

  @override
  Future<SendOtpResponse> sendSignupOtp(String email) async {
    return await remoteDataSource.sendSignupOtp(email);
  }

  @override
  Future<SendOtpResponse> sendOtp(String phone) async {
    final request = SendOtpRequest(phone: phone);
    return await remoteDataSource.sendOtp(request);
  }

  @override
  Future<VerifyOtpResponse> verifyOtp(String phone, String otp) async {
    final request = VerifyOtpRequest(phone: phone, otp: otp);
    final response = await remoteDataSource.verifyOtp(request);

    // Persist session tokens and user state
    await storageService.setString(StorageKeys.authToken, response.token);
    if (response.refreshToken != null) {
      await storageService.setString(
          StorageKeys.refreshToken, response.refreshToken!);
    }
    await storageService.setString(StorageKeys.userId, response.user.id);
    await storageService.setString(StorageKeys.userPhone, response.user.phone);
    await storageService.setBool(
        StorageKeys.isProfileComplete, response.user.isProfileComplete);
    await _saveUserToCache(response.user);

    return response;
  }

  @override
  Future<UserModel> completeProfile({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  }) async {
    final request = CompleteProfileRequest(
      name: name,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      profileImage: profileImage,
    );
    final updatedUser = await remoteDataSource.completeProfile(request);

    // Update session storage
    await storageService.setBool(
        StorageKeys.isProfileComplete, updatedUser.isProfileComplete);
    await _saveUserToCache(updatedUser);

    return updatedUser;
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final updatedUser = await remoteDataSource.updateProfile(data);
    await storageService.setBool(
        StorageKeys.isProfileComplete, updatedUser.isProfileComplete);
    await _saveUserToCache(updatedUser);
    return updatedUser;
  }

  @override
  Future<UserModel> updateClinicalPreferences(
      Map<String, dynamic> preferences) async {
    final updatedUser =
        await remoteDataSource.updateClinicalPreferences(preferences);
    await _saveUserToCache(updatedUser);
    return updatedUser;
  }

  @override
  Future<UserModel?> checkAuthSession() async {
    final token = storageService.getString(StorageKeys.authToken);
    final hasToken = token != null && token.isNotEmpty;
    debugPrint('STARTUP_AUTH [AuthRepository]: Stored auth token exists: $hasToken');

    if (!hasToken) {
      return null;
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      debugPrint(
          'STARTUP_AUTH [AuthRepository]: Fetched user profile (id: ${user.id}, isProfileComplete: ${user.isProfileComplete})');
      await _saveUserToCache(user);
      await storageService.setBool(
          StorageKeys.isProfileComplete, user.isProfileComplete);
      return user;
    } on UnauthorizedException {
      debugPrint('STARTUP_AUTH [AuthRepository]: Received 401 Unauthorized. Clearing session.');
      await logout();
      return null;
    } on ForbiddenException {
      debugPrint('STARTUP_AUTH [AuthRepository]: Received 403 Forbidden. Clearing session.');
      await logout();
      return null;
    } on NotFoundException {
      debugPrint('STARTUP_AUTH [AuthRepository]: Received 404 NotFound. Clearing session.');
      await logout();
      return null;
    } catch (e) {
      debugPrint('STARTUP_AUTH [AuthRepository]: Error fetching profile ($e). Falling back to cached user.');
      // If network fails offline, fall back to cached user session
      return await getCachedUser();
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final cachedJsonStr = storageService.getString(StorageKeys.userCachedJson);
    if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> json = jsonDecode(cachedJsonStr);
        return UserModel.fromJson(json);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Best-effort network logout
    } finally {
      await storageService.remove(StorageKeys.authToken);
      await storageService.remove(StorageKeys.refreshToken);
      await storageService.remove(StorageKeys.userId);
      await storageService.remove(StorageKeys.userPhone);
      await storageService.remove(StorageKeys.isProfileComplete);
      await storageService.remove(StorageKeys.userCachedJson);
    }
  }

  Future<void> _saveUserToCache(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await storageService.setString(StorageKeys.userCachedJson, jsonStr);
  }


  // @override
  // Future<RegisterCustomerResponse> registerCustomer(
  //     RegisterCustomerRequest request,
  //     ) async {
  //   final response = await remoteDataSource.registerCustomer(request);
  //
  //   // Save authentication tokens.
  //   await storageService.setString(
  //     StorageKeys.authToken,
  //     response.accessToken,
  //   );
  //
  //   if (response.refreshToken != null &&
  //       response.refreshToken!.isNotEmpty) {
  //     await storageService.setString(
  //       StorageKeys.refreshToken,
  //       response.refreshToken!,
  //     );
  //   }
  //
  //   // Save user details returned by the backend.
  //   final user = response.user;
  //
  //   final userId = user['id']?.toString();
  //   final phone = user['phone']?.toString();
  //
  //   if (userId != null && userId.isNotEmpty) {
  //     await storageService.setString(StorageKeys.userId, userId);
  //   }
  //
  //   if (phone != null && phone.isNotEmpty) {
  //     await storageService.setString(StorageKeys.userPhone, phone);
  //   }
  //
  //   // Registration leads to profile completion.
  //   await storageService.setBool(StorageKeys.isProfileComplete, false);
  //
  //   return response;
  // }
}
