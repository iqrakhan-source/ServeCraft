import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prop_crm/features/auth/data/models/register_customer_request.dart';
import 'package:prop_crm/features/auth/presentation/providers/auth_provider.dart';
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

  group('AuthProvider State Management', () {
    test('initial status is AuthStatus.initial', () {
      expect(authProvider.status, equals(AuthStatus.initial));
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('checkSession with empty storage yields AuthStatus.unauthenticated', () async {
      final status = await authProvider.checkSession();
      expect(status, equals(AuthStatus.unauthenticated));
      expect(authProvider.status, equals(AuthStatus.unauthenticated));
      expect(authProvider.currentUser, isNull);
    });

    test('sendOtp updates currentPhone and starts countdown', () async {
      final success = await authProvider.sendOtp('9876543210');
      expect(success, isTrue);
      expect(authProvider.currentPhone, equals('9876543210'));
      expect(authProvider.resendCountdown, equals(30));
      expect(authProvider.canResendOtp, isFalse);
    });

    test('sendSignupOtp updates currentEmail and starts countdown', () async {
      final success = await authProvider.sendSignupOtp('newuser@example.com');
      expect(success, isTrue);
      expect(authProvider.currentEmail, equals('newuser@example.com'));
      expect(authProvider.resendCountdown, equals(30));
      expect(authProvider.canResendOtp, isFalse);
    });

    test('sendSignupOtp fails for already registered email with meaningful error', () async {
      final success = await authProvider.sendSignupOtp('registered@example.com');
      expect(success, isFalse);
      expect(authProvider.hasError, isTrue);
      expect(authProvider.errorMessage, contains('already registered'));
    });

    test('verifyOtp for new user transitions to AuthStatus.profileIncomplete', () async {
      await authProvider.sendOtp('9876543210');
      final verified = await authProvider.verifyOtp('123456');

      expect(verified, isTrue);
      expect(authProvider.status, equals(AuthStatus.profileIncomplete));
      expect(authProvider.isProfileIncomplete, isTrue);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.isProfileComplete, isFalse);
    });

    test('verifyOtp for existing user transitions to AuthStatus.authenticated', () async {
      // Ending in '99' simulates existing user in mock data source
      await authProvider.sendOtp('9876543299');
      final verified = await authProvider.verifyOtp('123456');

      expect(verified, isTrue);
      expect(authProvider.status, equals(AuthStatus.authenticated));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser!.isProfileComplete, isTrue);
    });

    test('completeProfile transitions from profileIncomplete to authenticated', () async {
      await authProvider.sendOtp('9876543210');
      await authProvider.verifyOtp('123456');
      expect(authProvider.isProfileIncomplete, isTrue);

      final completed = await authProvider.completeProfile(
        name: 'Taylor Swift',
        email: 'taylor@example.com',
        gender: 'female',
        dateOfBirth: '13 Dec 1989',
        profileImage: 'https://example.com/avatar.jpg',
      );

      expect(completed, isTrue);
      expect(authProvider.status, equals(AuthStatus.authenticated));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser!.name, equals('Taylor Swift'));
      expect(authProvider.currentUser!.email, equals('taylor@example.com'));
      expect(authProvider.currentUser!.gender, equals('female'));
      expect(authProvider.currentUser!.dateOfBirth, equals('13 Dec 1989'));
      expect(authProvider.currentUser!.profileImage, equals('https://example.com/avatar.jpg'));
      expect(authProvider.currentUser!.isProfileComplete, isTrue);
    });

    test('logout resets status to unauthenticated', () async {
      await authProvider.sendOtp('9876543299');
      await authProvider.verifyOtp('123456');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.logout();
      expect(authProvider.status, equals(AuthStatus.unauthenticated));
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    test('registerCustomer sets current email, phone, user, and transitions to profileIncomplete', () async {
      final request = const RegisterCustomerRequest(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '9876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        gender: 'female',
      );

      final success = await authProvider.registerCustomer(request);
      expect(success, isTrue);
      expect(authProvider.status, equals(AuthStatus.profileIncomplete));
      expect(authProvider.isProfileIncomplete, isTrue);
      expect(authProvider.currentEmail, equals('jane@example.com'));
      expect(authProvider.currentPhone, equals('9876543210'));
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.name, equals('Jane Doe'));
    });

    test('registerCustomer fails on invalid request and sets error message', () async {
      final request = const RegisterCustomerRequest(
        name: 'J',
        email: 'jane@example.com',
        phone: '9876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        gender: 'female',
      );

      final success = await authProvider.registerCustomer(request);
      expect(success, isFalse);
      expect(authProvider.hasError, isTrue);
      expect(authProvider.status, equals(AuthStatus.error));
      expect(authProvider.errorMessage, isNotEmpty);
    });
  });
}
