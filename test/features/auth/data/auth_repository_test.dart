import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/storage/storage_keys.dart';
import 'package:prop_crm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prop_crm/features/auth/data/repositories/auth_repository_impl.dart';
import '../../../mocks/fake_storage_service.dart';

void main() {
  late FakeStorageService storageService;
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    storageService = FakeStorageService();
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: dataSource,
      storageService: storageService,
    );
  });

  group('AuthRepositoryImpl', () {
    test('sendOtp succeeds for valid 10-digit mobile number', () async {
      final response = await repository.sendOtp('9876543210');
      expect(response.success, isTrue);
      expect(response.expiresInSeconds, equals(30));
    });

    test('verifyOtp persists tokens and user session in storage', () async {
      final response = await repository.verifyOtp('9876543210', '123456');

      expect(response.token, isNotEmpty);
      expect(storageService.getString(StorageKeys.authToken), equals(response.token));
      expect(storageService.getString(StorageKeys.userId), equals(response.user.id));
      expect(storageService.getString(StorageKeys.userPhone), equals('9876543210'));
      expect(storageService.getString(StorageKeys.userCachedJson), isNotNull);
    });

    test('verifyOtp distinguishes existing user vs new user by backend data', () async {
      // Phone ending with '99' simulates existing user in mock
      final existingUserRes = await repository.verifyOtp('9876543299', '123456');
      expect(existingUserRes.isNewUser, isFalse);
      expect(existingUserRes.user.isProfileComplete, isTrue);

      // Other phone simulates new user
      final newUserRes = await repository.verifyOtp('9876543210', '123456');
      expect(newUserRes.isNewUser, isTrue);
      expect(newUserRes.user.isProfileComplete, isFalse);
    });

    test('completeProfile updates user and marks profile complete in storage', () async {
      await repository.verifyOtp('9876543210', '123456');

      final updatedUser = await repository.completeProfile(
        name: 'Jordan Lee',
        email: 'jordan@example.com',
      );

      expect(updatedUser.name, equals('Jordan Lee'));
      expect(updatedUser.isProfileComplete, isTrue);
      expect(storageService.getBool(StorageKeys.isProfileComplete), isTrue);
    });

    test('checkAuthSession returns null when not authenticated', () async {
      final session = await repository.checkAuthSession();
      expect(session, isNull);
    });

    test('checkAuthSession returns user when token exists in storage', () async {
      await repository.verifyOtp('9876543299', '123456');
      final session = await repository.checkAuthSession();
      expect(session, isNotNull);
      expect(session!.phone, equals('9876543299'));
    });

    test('logout clears session storage keys', () async {
      await repository.verifyOtp('9876543210', '123456');
      expect(storageService.getString(StorageKeys.authToken), isNotNull);

      await repository.logout();
      expect(storageService.getString(StorageKeys.authToken), isNull);
      expect(storageService.getString(StorageKeys.userId), isNull);
      expect(storageService.getString(StorageKeys.userPhone), isNull);
    });
  });
}
