import 'package:flutter/material.dart';

import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/utilities/extensions.dart';
import 'package:prop_crm/core/utilities/validators.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_text_field.dart';
import 'package:prop_crm/core/widgets/custom_app_bar.dart';
import 'package:prop_crm/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_service.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordScreen({super.key, this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthProvider>().forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        final token =
            context.read<StorageService>().getString(StorageKeys.resetToken) ??
            '';

        context.showSuccessSnackBar(
          'Password reset instructions sent to your email.',
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: _emailController.text.trim(),
              resetToken: token,
            ),
          ),
        );
      } else {
        context.showErrorSnackBar(
          context.read<AuthProvider>().errorMessage ??
              'Unable to request password reset.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      context.showErrorSnackBar(
        'Unable to request password reset. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Forgot Password',
        showBottomBorder: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 26,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Forgot Password?',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered email address to '
                  'request password reset instructions.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your registered email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AppValidators.validateEmail,
                  onSubmitted: (_) => _handleForgotPassword(),
                ),
                const SizedBox(height: 28),
                AppButton(
                  text: 'Send Reset Instructions',
                  isLoading: _isLoading,
                  onPressed: _handleForgotPassword,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Back to Login',
                      style: AppTypography.buttonMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_typography.dart';
// import '../../../../core/constants/route_names.dart';
// import '../../../../core/utilities/extensions.dart';
// import '../../../../core/utilities/validators.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
//
// class ForgotPasswordOtpScreen extends StatefulWidget {
//   final String? email;
//
//   const ForgotPasswordOtpScreen({super.key, this.email});
//
//   @override
//   State<ForgotPasswordOtpScreen> createState() =>
//       _ForgotPasswordOtpScreenState();
// }
//
// class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _otpController = TextEditingController();
//
//   int _resendCountdown = 30;
//   Timer? _countdownTimer;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }
//
//   @override
//   void dispose() {
//     _otpController.dispose();
//     _countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   void _startCountdown() {
//     _countdownTimer?.cancel();
//     setState(() {
//       _resendCountdown = 30;
//     });
//
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendCountdown > 0) {
//         setState(() {
//           _resendCountdown--;
//         });
//       } else {
//         _countdownTimer?.cancel();
//       }
//     });
//   }
//
//   void _handleResendOtp() {
//     if (_resendCountdown > 0) return;
//     _startCountdown();
//     context.showSuccessSnackBar(
//       'A new verification code has been sent to your email.',
//     );
//   }
//
//   Future<void> _handleVerifyOtp() async {
//     FocusScope.of(context).unfocus();
//
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     final targetEmail = widget.email ?? 'alex@example.com';
//     Navigator.of(context).pushReplacementNamed(
//       AppRoutes.resetPassword,
//       arguments: targetEmail,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final targetEmail = widget.email?.isNotEmpty == true
//         ? widget.email!
//         : 'your registered email';
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: const CustomAppBar(
//         title: 'Verification',
//         showBottomBorder: false,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 12),
//                 Text(
//                   'Verify Code',
//                   style: AppTypography.displayMedium.copyWith(
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: RichText(
//                         text: TextSpan(
//                           text: 'Enter the 6-digit code sent to ',
//                           style: AppTypography.bodyMedium.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: targetEmail,
//                               style: AppTypography.bodyMedium.copyWith(
//                                 color: AppColors.textPrimary,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         visualDensity: VisualDensity.compact,
//                       ),
//                       child: Text(
//                         'Change',
//                         style: AppTypography.buttonMedium.copyWith(
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 36),
//
//                 // 6-digit OTP Input
//                 AppTextField(
//                   controller: _otpController,
//                   label: '6-Digit Verification Code',
//                   hint: '• • • • • •',
//                   keyboardType: TextInputType.number,
//                   maxLength: 6,
//                   autofocus: true,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   validator: AppValidators.validateOtp,
//                   textInputAction: TextInputAction.done,
//                   onSubmitted: (_) => _handleVerifyOtp(),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Resend Timer Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     if (_resendCountdown > 0)
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.timer_outlined,
//                             size: 16,
//                             color: AppColors.textTertiary,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Resend code in ${_resendCountdown}s',
//                             style: AppTypography.bodyMedium.copyWith(
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       )
//                     else
//                       const SizedBox.shrink(),
//                     TextButton(
//                       onPressed: _resendCountdown <= 0 ? _handleResendOtp : null,
//                       child: Text(
//                         'Resend Code',
//                         style: AppTypography.buttonMedium.copyWith(
//                           color: _resendCountdown <= 0
//                               ? AppColors.primary
//                               : AppColors.textTertiary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Verify Button
//                 AppButton(
//                   text: 'Verify & Continue',
//                   isLoading: _isLoading,
//                   onPressed: _handleVerifyOtp,
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Prototype hint box
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.surfaceMuted,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: AppColors.border),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.info_outline_rounded,
//                         size: 18,
//                         color: AppColors.textSecondary,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'UI Prototype: Enter any 6 digits (e.g. 123456) to proceed to password reset.',
//                           style: AppTypography.bodySmall.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
