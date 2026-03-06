import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jarvis/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

const _user = AppUser(id: 'u1', email: 'test@test.com');

void main() {
  late MockAuthRemoteDatasource remote;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemoteDatasource();
    repo = AuthRepositoryImpl(remote);
  });

  group('signIn', () {
    test('returns user on success', () async {
      when(
        () => remote.signIn(email: 'test@test.com', password: 'pass'),
      ).thenAnswer((_) async => _user);

      final result = await repo.signIn(
        email: 'test@test.com',
        password: 'pass',
      );

      expect(result, const Right(_user));
    });

    test('returns server failure when datasource throws', () async {
      when(
        () => remote.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('invalid credentials'));

      final result = await repo.signIn(
        email: 'bad@test.com',
        password: 'wrong',
      );

      expect(result, const Left(Failure.server(message: 'Sign in failed')));
    });
  });

  group('signUp', () {
    test('returns user on success', () async {
      when(
        () => remote.signUp(email: 'new@test.com', password: 'pass'),
      ).thenAnswer((_) async => _user);

      final result = await repo.signUp(email: 'new@test.com', password: 'pass');

      expect(result, const Right(_user));
    });
  });

  group('signOut', () {
    test('returns unit on success', () async {
      when(() => remote.signOut()).thenAnswer((_) async {});

      final result = await repo.signOut();

      expect(result, const Right(unit));
    });

    test('returns failure when datasource throws', () async {
      when(() => remote.signOut()).thenThrow(Exception('network error'));

      expect(
        await repo.signOut(),
        const Left(Failure.server(message: 'Sign out failed')),
      );
    });
  });

  group('getCurrentUser', () {
    test('returns user when signed in', () async {
      when(() => remote.getCurrentUser()).thenReturn(_user);

      final result = await repo.getCurrentUser();

      expect(result, const Right(_user));
    });

    test('returns null when not signed in', () async {
      when(() => remote.getCurrentUser()).thenReturn(null);

      final result = await repo.getCurrentUser();

      expect(result.getRight().toNullable(), isNull);
    });
  });
}
