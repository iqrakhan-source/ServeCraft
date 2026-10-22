import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/error/error_handler.dart';
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
  bool _isResending = false;
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

  /// Register a customer using email and password.
  Future<bool> registerCustomer(
      RegisterCustomerRequest request,
      ) async {
    if (isLoading) return false;

    debugPrint('REGISTER [AuthProvider]: Initiating registration for ${request.email}');
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.registerCustomer(request);

      _currentEmail = request.email;
      _currentPhone = request.phone;
      if (response.user.isNotEmpty) {
        final userData = Map<String, dynamic>.from(response.user);
        if ((userData['email'] == null ||
                userData['email'].toString().isEmpty) &&
            request.email.isNotEmpty) {
          userData['email'] = request.email;
        }
        _currentUser = UserModel.fromJson(userData);
      }

      // Registration succeeded. The user still needs to
      // complete their profile in the next screen.
      _status = AuthStatus.profileIncomplete;
      debugPrint('REGISTER [AuthProvider]: Registration succeeded for ${request.email}');

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.handleError(e).message;
      _status = AuthStatus.error;
      debugPrint('REGISTER [AuthProvider]: Registration failed. Error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  /// Request Signup OTP for email address (POST /signup/send-otp)
  Future<bool> sendSignupOtp(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.sendSignupOtp(email);
      _currentEmail = email;
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

  /// Resend OTP using existing phone number or email
  Future<bool> resendOtp() async {
    if ((_currentPhone == null && _currentEmail == null) || !canResendOtp) return false;

    _isResending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = _currentEmail != null
          ? await repository.sendSignupOtp(_currentEmail!)
          : await repository.sendOtp(_currentPhone!);
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

  /// Submit profile completion for users
  Future<bool> completeProfile({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? profileImage,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.completeProfile(
        name: name,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
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

  /// Update profile using PATCH /api/v1/customer/profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await repository.updateProfile(data);
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

  /// Update clinical preferences using PATCH /api/v1/customer/profile/clinical-preferences
  Future<bool> updateClinicalPreferences(
      Map<String, dynamic> preferences) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser =
          await repository.updateClinicalPreferences(preferences);
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
