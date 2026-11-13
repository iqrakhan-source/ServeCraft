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
