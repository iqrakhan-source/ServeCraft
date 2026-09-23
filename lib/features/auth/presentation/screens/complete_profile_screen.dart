import 'package:flutter/material.dart';
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

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedAvatarUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final success = await authProvider.completeProfile(
      name: name,
      email: email.isNotEmpty ? email : null,
      profileImage: _selectedAvatarUrl,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainNav,
        (route) => false,
      );
    } else {
      context.showErrorSnackBar(
        authProvider.errorMessage ?? 'Failed to update profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final phone = authProvider.currentPhone ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Profile Setup',
        showBackButton: false,
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
                Text(
                  AppStrings.completeProfileTitle,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.completeProfileSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile photo selector
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: _selectedAvatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _selectedAvatarUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text.initials
                                      : 'SC',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            context.showSnackBar(
                              'Profile photo upload will connect to image picker.',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Read-only Phone Field
                AppTextField(
                  label: 'Registered Phone Number',
                  hint: AppFormatters.formatPhone(phone),
                  enabled: false,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name Field (Required)
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name *',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: AppValidators.validateName,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Email Address Field (Optional)
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address (Optional)',
                  hint: 'alex@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: (val) =>
                      AppValidators.validateEmail(val, isRequired: false),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleCompleteProfile(),
                ),
                const SizedBox(height: 36),

                // Submit Button
                AppButton(
                  text: 'Complete Profile & Continue',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleCompleteProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
