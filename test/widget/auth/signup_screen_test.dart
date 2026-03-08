import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/auth/presentation/screens/signup_screen.dart';

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async => const Left(Failure.server(message: 'stub'));

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async => const Left(Failure.server(message: 'stub'));

  @override
  Future<Either<Failure, Unit>> signOut() async => const Right(unit);

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async => const Right(null);

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);
}

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
    ],
    child: const MaterialApp(home: SignupScreen()),
  );
}

void main() {
  group('SignupScreen', () {
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('renders sign-up button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('sign_up_button')), findsOneWidget);
    });

    testWidgets('renders link to login', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.text(AppStrings.haveAccountSignIn), findsOneWidget);
    });

    testWidgets('shows validation error when password is too short', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.byKey(const Key('sign_up_button')));
      await tester.pump();
      expect(find.text(AppStrings.passwordTooShort), findsOneWidget);
    });

    testWidgets('calls signUp and shows error snackbar on failure', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'new@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('sign_up_button')));
      await tester.pump();
      await tester.pump();
      expect(find.text(AppStrings.authError), findsOneWidget);
    });
  });
}
