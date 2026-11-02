import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/constants/route_names.dart';
import 'package:prop_crm/core/widgets/app_button.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:prop_crm/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/forgot_password_otp_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/signup_screen.dart';
import '../../../mocks/fake_storage_service.dart';

void main() {
  late FakeStorageService storageService;
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;
  late AuthProvider authProvider;

  setUp(() {
    storageService = FakeStorageService();
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: dataSource,
      storageService: storageService,
    );
    authProvider = AuthProvider(repository: repository);
  });

  tearDown(() {
    authProvider.dispose();
  });

  Widget createTestWidget(Widget child) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        routes: {
          AppRoutes.mainNav: (_) => const Scaffold(body: Text('MainNavScreen')),
          AppRoutes.signup: (_) => const Scaffold(body: Text('SignupScreen')),
          AppRoutes.forgotPassword: (_) =>
              const Scaffold(body: Text('ForgotPasswordScreen')),
          AppRoutes.completeProfile: (_) =>
              const Scaffold(body: Text('CompleteProfileScreen')),
          AppRoutes.editProfile: (_) =>
              const Scaffold(body: Text('EditProfileScreen')),
          AppRoutes.login: (_) => const Scaffold(body: Text('LoginScreen')),
          AppRoutes.otpVerification: (_) =>
              const Scaffold(body: Text('OtpVerificationScreen')),
        },
        home: child,
      ),
    );
  }

  group('CRM Authentication Screens Widget Tests', () {
    testWidgets('LoginScreen renders email + password fields and validates inputs',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text(AppStrings.emailLabel), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.forgotPassword), findsOneWidget);
      expect(find.widgetWithText(AppButton, AppStrings.signIn), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Tap Sign In with empty fields to trigger validation
      await tester.tap(find.widgetWithText(AppButton, AppStrings.signIn));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Enter valid credentials and verify error disappears
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'alex@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.tap(find.widgetWithText(AppButton, AppStrings.signIn));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('MainNavScreen'), findsOneWidget);
    });

    testWidgets(
        'SignupScreen validates password match, calls registerCustomer, and navigates to CompleteProfileScreen',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const SignupScreen()));

      expect(find.text(AppStrings.signUpTitle), findsNWidgets(2));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text(AppStrings.emailLabel), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.confirmPasswordLabel), findsOneWidget);
      expect(find.widgetWithText(AppButton, AppStrings.signUp), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'janedoe@example.com');
      await tester.enterText(textFields.at(2), '9876543210');

      // Select gender
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('female').last);
      await tester.pumpAndSettle();

      // Enter mismatched passwords
      await tester.enterText(textFields.at(3), 'Secret123!');
      await tester.enterText(textFields.at(4), 'Different123!');

      final submitBtn = find.widgetWithText(AppButton, AppStrings.signUp);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);

      // Fix confirm password to match and submit to trigger customer registration
      await tester.enterText(textFields.at(4), 'Secret123!');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Successfully called registerCustomer and navigated to complete profile screen
      expect(find.text('CompleteProfileScreen'), findsOneWidget);
    });

    testWidgets(
        'SignupScreen stops loading, displays meaningful error, and remains on screen when API fails',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const SignupScreen()));

      final textFields = find.byType(TextField);
      // 'J' triggers MockAuthRemoteDataSource name validation failure
      await tester.enterText(textFields.at(0), 'J');
      await tester.enterText(textFields.at(1), 'janedoe@example.com');
      await tester.enterText(textFields.at(2), '9876543210');

      // Select gender
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('female').last);
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(3), 'Secret123!');
      await tester.enterText(textFields.at(4), 'Secret123!');

      final submitBtn = find.widgetWithText(AppButton, AppStrings.signUp);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // User remains on Signup screen (does not navigate to CompleteProfileScreen)
      expect(find.text('CompleteProfileScreen'), findsNothing);
      expect(find.text(AppStrings.signUpTitle), findsNWidgets(2));
      // Meaningful error message is displayed
      expect(find.text('Please enter a valid name'), findsOneWidget);
    });

    testWidgets(
        'CompleteProfileScreen renders customer profile fields including editable phone and preferences',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const CompleteProfileScreen()));

      expect(find.text(AppStrings.completeProfileTitle), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Gender (Optional)'), findsOneWidget);
      expect(find.text('Date of Birth (Optional)'), findsOneWidget);
      expect(find.text('Preferred Salon Services (Optional)'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Save & Continue'), findsOneWidget);

      // Validate required name
      final saveBtn = find.widgetWithText(AppButton, 'Save & Continue');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);

      // Enter name and phone number
      final nameField = find.widgetWithText(TextField, 'Enter your full name');
      await tester.enterText(nameField, 'Eleanor Vance');

      final phoneField =
          find.widgetWithText(TextField, AppStrings.phoneHint);
      await tester.enterText(phoneField, '9876543210');

      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('MainNavScreen'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen validates email and navigates to OTP',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              AppRoutes.forgotPasswordOtp: (_) =>
                  const Scaffold(body: Text('ForgotPasswordOtpScreen')),
            },
            home: const ForgotPasswordScreen(),
          ),
        ),
      );

      expect(find.text(AppStrings.forgotPasswordTitle), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);

      // Tap Send without email
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();
      expect(find.text('Email address is required'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Enter valid email and submit
      await tester.enterText(find.byType(TextField), 'sarah@example.com');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('ForgotPasswordOtpScreen'), findsOneWidget);
    });

    testWidgets('ForgotPasswordOtpScreen validates 6-digit OTP', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              AppRoutes.resetPassword: (_) =>
                  const Scaffold(body: Text('ResetPasswordScreen')),
            },
            home: const ForgotPasswordOtpScreen(email: 'sarah@example.com'),
          ),
        ),
      );

      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.text('Verify & Continue'), findsOneWidget);

      // Tap verify with empty OTP
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter OTP'), findsOneWidget);

      // Enter 4 digits
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      expect(find.text('OTP must be 6 digits'), findsOneWidget);

      // Enter valid 6 digits
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('ResetPasswordScreen'), findsOneWidget);
    });

    testWidgets('ResetPasswordScreen validates and resets password',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              AppRoutes.login: (_) => const Scaffold(body: Text('LoginScreen')),
            },
            home: const ResetPasswordScreen(email: 'sarah@example.com'),
          ),
        ),
      );

      expect(find.text(AppStrings.resetPasswordTitle), findsNWidgets(2));
      expect(find.widgetWithText(AppButton, AppStrings.resetPasswordBtn),
          findsOneWidget);

      // Enter matching valid new passwords
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'newpassword123');
      await tester.enterText(textFields.at(1), 'newpassword123');

      final resetBtn =
          find.widgetWithText(AppButton, AppStrings.resetPasswordBtn);
      await tester.ensureVisible(resetBtn);
      await tester.tap(resetBtn);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify success dialog
      expect(find.text('Password Updated'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);

      // Tap confirm button on alert
      await tester.tap(find.text('Back to Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('LoginScreen'), findsOneWidget);
    });
  });
}
