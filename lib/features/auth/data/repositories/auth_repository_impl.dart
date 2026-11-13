import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/storage/storage_keys.dart';
import 'package:prop_crm/core/storage/storage_service.dart';
import '../../../../core/networking/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/aesthetic_preferences_request.dart';
import '../models/change_password_request.dart';
import '../models/complete_profile_request.dart';
import '../models/register_customer_request.dart';
import '../models/register_customer_response.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/user_model.dart';
import '../models/login_response.dart';
import '../models/forgot_password_request.dart';
import '../models/password_reset_response.dart';
import '../models/reset_password_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<LoginResponse> login(String identifier, String password) async {
    final response = await remoteDataSource.login(identifier, password);

    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Login failed. Please check your credentials.',
      );
    }

    final token = response.accessToken.isNotEmpty
        ? response.accessToken
        : response.token;

    if (token.isNotEmpty) {
      await storageService.setString(StorageKeys.authToken, token);
    }

    if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
      await storageService.setString(
        StorageKeys.refreshToken,
        response.refreshToken!,
      );
    }

    await storageService.setString(StorageKeys.userId, response.user.id);

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
    debugPrint('REGISTER [AuthRepository]: Registering ${request.email}');

    try {
      final response = await remoteDataSource.registerCustomer(request);

      await storageService.setString(
        StorageKeys.authToken,
        response.accessToken,
      );

      if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
        await storageService.setString(
          StorageKeys.refreshToken,
          response.refreshToken!,
        );
      }

      final userId = (response.user['id'] ?? response.user['_id'])?.toString();
      final phone = response.user['phone']?.toString() ?? request.phone;

      if (userId != null && userId.isNotEmpty) {
        await storageService.setString(StorageKeys.userId, userId);
      }

      if (phone != null && phone.isNotEmpty) {
        await storageService.setString(StorageKeys.userPhone, phone);
      }

      await storageService.setBool(
        StorageKeys.isProfileComplete,
        response.isProfileComplete,
      );

      if (response.userModel != null) {
        await _saveUserToCache(response.userModel!);
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('REGISTER [AuthRepository] ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> refreshToken() async {
    final currentRefreshToken = storageService.getString(
      StorageKeys.refreshToken,
    );
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return false;
    }

    try {
      final data = await remoteDataSource.refreshToken(currentRefreshToken);
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await storageService.setString(StorageKeys.authToken, newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storageService.setString(
            StorageKeys.refreshToken,
            newRefreshToken,
          );
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
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
  Future<bool> changePassword(ChangePasswordRequest request) async {
    return await remoteDataSource.changePassword(request);
  }

  @override
  Future<SendOtpResponse> sendOtp(String phone) async {
    final request = SendOtpRequest(phone: phone);
    return await remoteDataSource.sendOtp(request);
  }

  @override
  Future<UserModel> completeProfile({
    required String name,
    String? phone,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  }) async {
    final request = CompleteProfileRequest(
      name: name,
      phone: phone,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      profileImage: profileImage,
    );

    final updatedUser = await remoteDataSource.completeProfile(request);

    await storageService.setBool(
      StorageKeys.isProfileComplete,
      updatedUser.isProfileComplete,
    );

    if (updatedUser.phone.isNotEmpty) {
      await storageService.setString(StorageKeys.userPhone, updatedUser.phone);
    }

    await _saveUserToCache(updatedUser);

    return updatedUser;
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final updatedUser = await remoteDataSource.updateProfile(data);
    await storageService.setBool(
      StorageKeys.isProfileComplete,
      updatedUser.isProfileComplete,
    );
    if (updatedUser.phone.isNotEmpty) {
      await storageService.setString(StorageKeys.userPhone, updatedUser.phone);
    }
    await _saveUserToCache(updatedUser);
    return updatedUser;
  }

  @override
  Future<String> uploadProfilePhoto(dynamic fileOrPath) async {
    final photoUrl = await remoteDataSource.uploadProfilePhoto(fileOrPath);
    final cached = await getCachedUser();
    if (cached != null && photoUrl.isNotEmpty) {
      final updated = cached.copyWith(profileImage: photoUrl);
      await _saveUserToCache(updated);
    }
    return photoUrl;
  }

  @override
  Future<bool> registerFcmToken(String fcmToken) async {
    return await remoteDataSource.registerFcmToken(fcmToken);
  }

  @override
  Future<bool> updateAestheticPreferences(
    AestheticPreferencesRequest preferences,
  ) async {
    return await remoteDataSource.updateAestheticPreferences(preferences);
  }

  @override
  Future<UserModel?> checkAuthSession() async {
    final token = storageService.getString(StorageKeys.authToken);
    final hasToken = token != null && token.isNotEmpty;

    if (!hasToken) {
      return null;
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      await _saveUserToCache(user);
      await storageService.setBool(
        StorageKeys.isProfileComplete,
        user.isProfileComplete,
      );
      return user;
    } on UnauthorizedException {
      await logout();
      return null;
    } on ForbiddenException {
      await logout();
      return null;
    } on NotFoundException {
      await logout();
      return null;
    } catch (e) {
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
}
