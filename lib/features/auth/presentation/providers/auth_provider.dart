import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

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
  String? _errorMessage;
  int _resendCountdown = 0;
  bool _isResending = false;
  Timer? _countdownTimer;

  AuthProvider({required this.repository});

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get currentPhone => _currentPhone;
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
        // Determine whether profile completion is needed based on backend user data
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

    notifyListeners();
    return _status;
  }

  /// Request OTP for mobile number
  Future<bool> sendOtp(String phone) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.sendOtp(phone);
      _currentPhone = phone;
      _status = AuthStatus.initial;
      startResendCountdown(response.expiresInSeconds);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Resend OTP using existing phone number
  Future<bool> resendOtp() async {
    if (_currentPhone == null || !canResendOtp) return false;

    _isResending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.sendOtp(_currentPhone!);
      startResendCountdown(response.expiresInSeconds);
      _isResending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _isResending = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify 6-digit OTP code
  Future<bool> verifyOtp(String otp) async {
    if (_currentPhone == null) {
      _errorMessage = 'Phone number missing. Please restart login.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.verifyOtp(_currentPhone!, otp);
      _currentUser = response.user;
      cancelResendCountdown();

      // Determine next screen based on backend response:
      if (!response.user.isProfileComplete) {
        _status = AuthStatus.profileIncomplete;
      } else {
        _status = AuthStatus.authenticated;
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

  /// Submit mandatory profile completion for new users
  Future<bool> completeProfile({
    required String name,
    String? email,
    String? profileImage,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.completeProfile(
        name: name,
        email: email,
        profileImage: profileImage,
      );
      _currentUser = updatedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Clear session & logout
  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    _currentPhone = null;
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
