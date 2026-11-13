import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/extensions.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../../data/models/register_customer_request.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  Future<void> _selectDateOfBirth() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      debugPrint('REGISTER [UI]: Form validation failed');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoading) return;

    setState(() => _isLoading = true);
    debugPrint(
      'REGISTER [UI]: Form validated. Submitting registration for '
      'name: ${_nameController.text.trim()}, email: ${_emailController.text.trim()}, '
      'phone: ${_phoneController.text.trim()}, gender: $_selectedGender',
    );

    final dobFormatted = DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!);

    try {
      final request = RegisterCustomerRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        gender: _selectedGender!,
        dob: dobFormatted,
      );

      final success = await authProvider.registerCustomer(request);

      if (!mounted) return;

      if (success) {
        debugPrint('REGISTER [UI]: Registration succeeded.');
        context.showSuccessSnackBar('Account created successfully.');

        final isComplete = authProvider.isProfileComplete;
        if (isComplete) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.mainNav, (route) => false);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.completeProfile);
        }
      } else {
        debugPrint(
          'REGISTER [UI]: Registration failed. Remaining on SignupScreen. '
          'Error: ${authProvider.errorMessage}',
        );
        context.showErrorSnackBar(
          authProvider.errorMessage ?? AppStrings.commonError,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('REGISTER [UI]: Registration caught exception: $e');
      context.showErrorSnackBar(
        authProvider.errorMessage ?? 'Registration failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isSubmitting = _isLoading || authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          tooltip: 'Back to Login',
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon branding
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.content_cut_rounded,
                        size: 24,
                        color: AppColors.textInverse,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 10,
                          color: AppColors.secondary.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  AppStrings.signUpTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  AppStrings.signUpSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Full name
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),

                const SizedBox(height: 18),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailHint,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      AppValidators.validateEmail(value, isRequired: true),
                ),

                const SizedBox(height: 18),

                // Phone number
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your 10-digit phone number',
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _validatePhone,
                ),

                const SizedBox(height: 18),

                // Gender
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'female', child: Text('female')),
                    DropdownMenuItem(value: 'male', child: Text('male')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          setState(() => _selectedGender = value);
                        },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select your gender'
                      : null,
                ),

                const SizedBox(height: 18),

                // Date of Birth (Mandatory)
                FormField<DateTime>(
                  initialValue: _selectedDateOfBirth,
                  validator: (_) {
                    if (_selectedDateOfBirth == null) {
                      return 'Please select your date of birth';
                    }
                    if (_selectedDateOfBirth!.isAfter(DateTime.now())) {
                      return 'Date of birth cannot be in the future';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date of Birth',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: isSubmitting
                              ? null
                              : () async {
                                  await _selectDateOfBirth();
                                  state.didChange(_selectedDateOfBirth);
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: state.hasError
                                    ? AppColors.error
                                    : AppColors.border,
                                width: state.hasError ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.cake_outlined,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDateOfBirth != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_selectedDateOfBirth!)
                                        : 'Select date of birth',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: _selectedDateOfBirth != null
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.hasError) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              state.errorText!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                // Password
                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  hint: 'Create a password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.validatePassword,
                ),

                const SizedBox(height: 18),

                // Confirm password
                AppTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPasswordLabel,
                  hint: 'Confirm your password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isSubmitting) _handleSignup();
                  },
                  validator: (value) => AppValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),

                const SizedBox(height: 28),

                // Create account
                AppButton(
                  text: AppStrings.signUp,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _handleSignup,
                ),

                const SizedBox(height: 24),

                // Existing account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          AppStrings.signIn,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'By signing up, you agree to our Terms of Service & Privacy Policy',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
