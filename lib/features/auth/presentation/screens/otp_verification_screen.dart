import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/extensions.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/utilities/validators.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_text_field.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? phone;

  const OtpVerificationScreen({super.key, this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final otp = _otpController.text.trim();

    final success = await authProvider.verifyOtp(otp);
    if (!mounted) return;

    if (success) {
      if (authProvider.isProfileComplete) {
        // Existing user: direct to Main Navigation
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.mainNav,
          (route) => false,
        );
      } else {
        // New user: direct to Complete Profile
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.completeProfile,
        );
      }
    } else {
      context.showErrorSnackBar(
        authProvider.errorMessage ?? 'Invalid OTP. Please try again.',
      );
    }
  }

  Future<void> _handleResendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendOtp();
    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('A new verification code has been sent.');
    } else {
      context.showErrorSnackBar(
        authProvider.errorMessage ?? 'Failed to resend OTP.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final targetPhone = widget.phone ?? authProvider.currentPhone ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Verification',
        showBottomBorder: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  AppStrings.otpTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppStrings.otpSubtitle} ${AppFormatters.formatPhone(targetPhone)}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Edit',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // 6-digit OTP Input
                AppTextField(
                  controller: _otpController,
                  label: '6-Digit Verification Code',
                  hint: '• • • • • •',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: AppValidators.validateOtp,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleVerifyOtp(),
                ),
                const SizedBox(height: 16),

                // Resend timer and button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (authProvider.resendCountdown > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${authProvider.resendCountdown}s',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    TextButton(
                      onPressed: authProvider.canResendOtp
                          ? _handleResendOtp
                          : null,
                      child: authProvider.isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : Text(
                              AppStrings.resendOtp,
                              style: AppTypography.buttonMedium.copyWith(
                                color: authProvider.canResendOtp
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Verify & Proceed Button
                AppButton(
                  text: AppStrings.verifyOtp,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleVerifyOtp,
                ),

                const SizedBox(height: 32),

                // Hint box for testing
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Test tip: In development mode, enter any 6 digits (e.g. 123456) to verify.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
