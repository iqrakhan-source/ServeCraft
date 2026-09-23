import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:prop_crm/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/mobile_login_screen.dart';
import 'package:prop_crm/features/auth/presentation/screens/otp_verification_screen.dart';
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
        home: child,
      ),
    );
  }

  group('Auth Screens Widget Tests', () {
    testWidgets('MobileLoginScreen validates empty or invalid phone number', (tester) async {
      await tester.pumpWidget(createTestWidget(const MobileLoginScreen()));

      expect(find.text('Enter Mobile Number'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      // Tap Send OTP without entering phone
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile number is required'), findsOneWidget);

      // Enter invalid phone
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen validates OTP input length', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const OtpVerificationScreen(phone: '9876543210')),
      );

      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('Verify & Proceed'), findsOneWidget);

      // Tap Verify without entering OTP
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter OTP'), findsOneWidget);

      // Enter partial 4 digits
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('OTP must be 6 digits'), findsOneWidget);
    });

    testWidgets('CompleteProfileScreen validates required name', (tester) async {
      await tester.pumpWidget(createTestWidget(const CompleteProfileScreen()));

      expect(find.text('Complete Your Profile'), findsOneWidget);

      // Scroll into view and tap submit with empty name
      final submitButton = find.text('Complete Profile & Continue');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
    });
  });
}
