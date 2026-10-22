import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Show success dialog and navigate back to Login
    await AppDialog.alert(
      context: context,
      title: 'Password Updated',
      message:
          'Your password has been reset successfully. You can now log in with your new credentials.',
      buttonText: 'Back to Sign In',
    );

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Branding mark
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
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
                  child: const Center(
                    child: Icon(
                      Icons.key_rounded,
                      size: 26,
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Heading & Subtitle
                Text(
                  AppStrings.resetPasswordTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.resetPasswordSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // New Password Field
                AppTextField(
                  controller: _newPasswordController,
                  label: AppStrings.newPasswordLabel,
                  hint: 'Enter new password (min 6 characters)',
                  obscureText: _obscureNewPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: _toggleNewPasswordVisibility,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.validatePassword,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),

                // Confirm Password Field
                AppTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPasswordLabel,
                  hint: 'Confirm your new password',
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
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleResetPassword(),
                  validator: (val) => AppValidators.validateConfirmPassword(
                    val,
                    _newPasswordController.text,
                  ),
                ),
                const SizedBox(height: 20),

                // Password strength helper note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _newPasswordController.text.length >= 6
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: _newPasswordController.text.length >= 6
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'At least 6 characters',
                            style: AppTypography.bodySmall.copyWith(
                              color: _newPasswordController.text.length >= 6
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary CTA
                AppButton(
                  text: AppStrings.resetPasswordBtn,
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
