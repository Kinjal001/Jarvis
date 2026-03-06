import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jarvis/features/auth/domain/usecases/get_current_user.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_in.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_out.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_up.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const _user = AppUser(id: 'u1', email: 'test@test.com');

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  group('SignIn', () {
    test('returns user on successful sign in', () async {
      when(
        () => repo.signIn(email: 'test@test.com', password: 'pass123'),
      ).thenAnswer((_) async => const Right(_user));

      final result = await SignIn(
        repo,
      ).call(email: 'test@test.com', password: 'pass123');

      expect(result, const Right(_user));
    });

    test('returns failure on invalid credentials', () async {
      const failure = Failure.server(message: 'Invalid credentials');
      when(
        () => repo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await SignIn(
        repo,
      ).call(email: 'bad@email.com', password: 'wrong');

      expect(result, const Left(failure));
    });
  });

  group('SignUp', () {
    test('returns new user on successful registration', () async {
      when(
        () => repo.signUp(email: 'new@test.com', password: 'pass123'),
      ).thenAnswer((_) async => const Right(_user));

      final result = await SignUp(
        repo,
      ).call(email: 'new@test.com', password: 'pass123');

      expect(result, const Right(_user));
    });
  });

  group('SignOut', () {
    test('returns unit on successful sign out', () async {
      when(() => repo.signOut()).thenAnswer((_) async => const Right(unit));

      final result = await SignOut(repo).call();

      expect(result, const Right(unit));
      verify(() => repo.signOut()).called(1);
    });

    test('returns failure when sign out fails', () async {
      const failure = Failure.network(message: 'offline');
      when(() => repo.signOut()).thenAnswer((_) async => const Left(failure));

      expect(await SignOut(repo).call(), const Left(failure));
    });
  });

  group('GetCurrentUser', () {
    test('returns user when signed in', () async {
      when(
        () => repo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(_user));

      expect(await GetCurrentUser(repo).call(), const Right(_user));
    });

    test('returns null when not signed in', () async {
      when(
        () => repo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(null));

      final result = await GetCurrentUser(repo).call();

      expect(result.getRight().toNullable(), isNull);
    });
  });
}
