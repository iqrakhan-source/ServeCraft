import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/extensions.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordOtpScreen({super.key, this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  int _resendCountdown = 30;
  Timer? _countdownTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  void _handleResendOtp() {
    if (_resendCountdown > 0) return;
    _startCountdown();
    context.showSuccessSnackBar(
      'A new verification code has been sent to your email.',
    );
  }

  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final targetEmail = widget.email ?? 'alex@example.com';
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.resetPassword,
      arguments: targetEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetEmail = widget.email?.isNotEmpty == true
        ? widget.email!
        : 'your registered email';

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
                const SizedBox(height: 12),
                Text(
                  'Verify Code',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'Enter the 6-digit code sent to ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: targetEmail,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                        'Change',
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

                // Resend Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_resendCountdown > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${_resendCountdown}s',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    TextButton(
                      onPressed: _resendCountdown <= 0 ? _handleResendOtp : null,
                      child: Text(
                        'Resend Code',
                        style: AppTypography.buttonMedium.copyWith(
                          color: _resendCountdown <= 0
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Verify Button
                AppButton(
                  text: 'Verify & Continue',
                  isLoading: _isLoading,
                  onPressed: _handleVerifyOtp,
                ),
                const SizedBox(height: 32),

                // Prototype hint box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'UI Prototype: Enter any 6 digits (e.g. 123456) to proceed to password reset.',
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
