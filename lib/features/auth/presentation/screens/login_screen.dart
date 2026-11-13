import 'package:flutter/material.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utilities/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Future<void> _handleLogin() async {
  //   FocusScope.of(context).unfocus();
  //
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }
  //
  //   // UI-only prototype: simulate short interaction and navigate to Home / MainNav
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   await Future.delayed(const Duration(milliseconds: 600));
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _isLoading = false;
  //   });
  //
  //
  //
  //   Navigator.of(context).pushNamedAndRemoveUntil(
  //     AppRoutes.mainNav,
  //     (route) => false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Salon Logo Mark
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.content_cut_rounded,
                            size: 30,
                            color: AppColors.textInverse,
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: AppColors.secondary.withValues(
                                alpha: 0.95,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Welcome Heading & Subtitle
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.emailLoginSubtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email Field
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
                    validator: (val) =>
                        AppValidators.validateEmail(val, isRequired: true),
                  ),
                  const SizedBox(height: 18),

                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    label: AppStrings.passwordLabel,
                    hint: AppStrings.passwordHint,
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
                      onPressed: _togglePasswordVisibility,
                    ),
                    textInputAction: TextInputAction.done,
                    // onSubmitted: (_) => _handleLogin(),
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password Action
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary Sign In Button
                  AppButton(
                    text: AppStrings.signIn,
                    isLoading: _isLoading,

                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        debugPrint('[LOGIN UI] Login button pressed');
                        debugPrint(
                          '[LOGIN UI] Email: ${_emailController.text.trim()}',
                        );

                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        final success = await authProvider.login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        debugPrint('[LOGIN UI] Success: $success');
                        debugPrint(
                          '[LOGIN UI] Error: ${authProvider.errorMessage}',
                        );
                        debugPrint(
                          '[LOGIN UI] Profile incomplete: ${authProvider.isProfileIncomplete}',
                        );

                        if (!context.mounted) return;

                        if (success) {
                          final nextRoute = authProvider.isProfileIncomplete
                              ? AppRoutes.completeProfile
                              : AppRoutes.mainNav;

                          debugPrint('[LOGIN UI] Navigating to: $nextRoute');

                          Navigator.of(context).pushNamedAndRemoveUntil(
                            nextRoute,
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.errorMessage ??
                                    'Login failed. Please check your credentials.',
                              ),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        debugPrint('[LOGIN UI] Exception: $e');
                        debugPrintStack(stackTrace: stackTrace);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to log in. Please try again.',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'or',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Sign Up Navigation Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.signup);
                        },
                        child: Text(
                          'Create Account',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subtle dev tip banner for prototype preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'UI Prototype: Enter any valid email and 6+ character password to preview Home, or tap Create Account to preview Sign Up.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
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
      ),
    );
  }
}
