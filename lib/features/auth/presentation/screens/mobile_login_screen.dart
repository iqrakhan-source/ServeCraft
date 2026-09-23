import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/utilities/extensions.dart';
import 'package:prop_crm/core/utilities/validators.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/core/widgets/app_text_field.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();

    final success = await authProvider.sendOtp(phone);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: phone,
      );
    } else {
      context.showErrorSnackBar(
        authProvider.errorMessage ?? AppStrings.commonError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // App Logo mark
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    size: 28,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: 32),

                // Title & Subtitle
                Text(
                  AppStrings.loginTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // Phone Input Field
                AppTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hint: '98765 43210',
                  prefixText: '+91',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: AppValidators.validatePhone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSendOtp(),
                ),
                const SizedBox(height: 24),

                // Send OTP Button
                AppButton(
                  text: AppStrings.sendOtp,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleSendOtp,
                ),
                const SizedBox(height: 24),

                // Terms disclaimer
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service & Privacy Policy',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Mock test hint banner for development testing
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
                          'Test tip: Phone ending in "99" simulates an Existing User, other numbers simulate a New User.',
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
