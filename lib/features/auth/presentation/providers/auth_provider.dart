import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/aesthetic_preferences_request.dart';
import '../../data/models/change_password_request.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/reset_password_request.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/register_customer_request.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  profileIncomplete,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _currentPhone;
  String? _currentEmail;
  String? _errorMessage;
  int _resendCountdown = 0;
  final bool _isResending = false;
  Timer? _countdownTimer;

  AuthProvider({required this.repository});

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get currentPhone => _currentPhone;
  String? get currentEmail => _currentEmail;
  String? get errorMessage => _errorMessage;
  int get resendCountdown => _resendCountdown;
  bool get isResending => _isResending;
  bool get canResendOtp => _resendCountdown <= 0 && !_isResending;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isProfileIncomplete => _status == AuthStatus.profileIncomplete;
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;
  bool get hasError => _status == AuthStatus.error;

  /// Check active session during Splash
  Future<AuthStatus> checkSession() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await repository.checkAuthSession();
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      } else {
        _currentUser = user;
        _currentPhone = user.phone;
        _currentEmail = user.email;
        if (!user.isProfileComplete) {
          _status = AuthStatus.profileIncomplete;
        } else {
          _status = AuthStatus.authenticated;
        }
      }
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
    }

    debugPrint(
      'STARTUP_AUTH [AuthProvider]: status: $_status, isProfileComplete: ${_currentUser?.isProfileComplete}',
    );
    notifyListeners();
    return _status;
  }

  /// Register a customer
  Future<bool> registerCustomer(RegisterCustomerRequest request) async {
    if (isLoading) return false;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.registerCustomer(request);

      _currentEmail = request.email;
      _currentPhone = request.phone;

      if (response.userModel != null) {
        _currentUser = response.userModel;
      } else if (response.user.isNotEmpty) {
        _currentUser = UserModel.fromJson(response.user);
      }

      if (response.isProfileComplete ||
          (_currentUser?.isProfileComplete ?? false)) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.profileIncomplete;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Customer Login (Email or Phone)
  Future<bool> login(String identifier, String password) async {
    if (isLoading) return false;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.login(identifier, password);

      _currentUser = response.user;
      _currentEmail = response.user.email.isNotEmpty
          ? response.user.email
          : identifier;
      _currentPhone = response.user.phone;

      if (response.isProfileComplete && response.user.isProfileComplete) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.profileIncomplete;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Request Password Reset
  Future<bool> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.forgotPassword(
        ForgotPasswordRequest(email: email.trim()),
      );

      if (!response.success) {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to request password reset.',
        );
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Reset Password with Token
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.resetPassword(
        ResetPasswordRequest(resetToken: resetToken, newPassword: newPassword),
      );

      if (!response.success) {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to reset password.',
        );
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Change Password (Auth required)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await repository.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

      if (success) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to update password');
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Submit profile completion
  Future<bool> completeProfile({
    required String name,
    String? phone,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  }) async {
    if (isLoading) return false;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.completeProfile(
        name: name,
        phone: phone,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        profileImage: profileImage,
      );

      _currentUser = updatedUser;
      _status = updatedUser.isProfileComplete
          ? AuthStatus.authenticated
          : AuthStatus.profileIncomplete;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('PROFILE UPDATE [Provider] Failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Update profile data
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.updateProfile(data);
      _currentUser = updatedUser;
      _status = updatedUser.isProfileComplete
          ? AuthStatus.authenticated
          : AuthStatus.profileIncomplete;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Upload avatar/photo
  Future<String?> uploadProfilePhoto(dynamic fileOrPath) async {
    try {
      final url = await repository.uploadProfilePhoto(fileOrPath);
      if (_currentUser != null && url.isNotEmpty) {
        _currentUser = _currentUser!.copyWith(profileImage: url);
        notifyListeners();
      }
      return url;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      notifyListeners();
      return null;
    }
  }

  /// Register mobile device FCM Token
  Future<bool> registerFcmToken(String fcmToken) async {
    try {
      return await repository.registerFcmToken(fcmToken);
    } catch (_) {
      return false;
    }
  }

  /// Update aesthetic preferences (stylist consultation)
  Future<bool> updateAestheticPreferences(
    AestheticPreferencesRequest preferences,
  ) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await repository.updateAestheticPreferences(preferences);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    _currentPhone = null;
    _currentEmail = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    cancelResendCountdown();
    notifyListeners();
  }

  void startResendCountdown([int seconds = 30]) {
    cancelResendCountdown();
    _resendCountdown = seconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        cancelResendCountdown();
      }
    });
  }

  void cancelResendCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    cancelResendCountdown();
    super.dispose();
  }
}
