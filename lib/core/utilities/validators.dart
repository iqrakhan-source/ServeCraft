abstract class AppValidators {
  static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _pincodeRegex = RegExp(r'^\d{6}$');
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  /// Validates standard 10-digit mobile number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (!clean.startsWith(RegExp(r'[6-9]')) || clean.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!_phoneRegex.hasMatch(clean)) {
      return 'Mobile number must contain digits only';
    }
    return null;
  }

  /// Validates 6-digit OTP
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter OTP';
    }
    if (value.trim().length != 6 || !_otpRegex.hasMatch(value.trim())) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  /// Validates customer full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates optional or mandatory email
  static String? validateEmail(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Email address is required';
      return null;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates 6-digit Indian PIN code
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!_pincodeRegex.hasMatch(value.trim())) {
      return 'Pincode must be 6 digits';
    }
    return null;
  }

  /// Generic required field validator
  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
