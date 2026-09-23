import 'dart:convert';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/storage/storage_keys.dart';
import 'package:prop_crm/core/storage/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/complete_profile_request.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

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
    String? profileImage,
  }) async {
    final request = CompleteProfileRequest(
      name: name,
      email: email,
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
  Future<UserModel?> checkAuthSession() async {
    final token = storageService.getString(StorageKeys.authToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      await _saveUserToCache(user);
      await storageService.setBool(
          StorageKeys.isProfileComplete, user.isProfileComplete);
      return user;
    } on UnauthorizedException {
      await logout();
      return null;
    } catch (_) {
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
}
