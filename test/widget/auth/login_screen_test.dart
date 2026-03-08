import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/auth/presentation/screens/login_screen.dart';

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
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('renders sign-in button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
    });

    testWidgets('renders link to signup', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.text(AppStrings.noAccountSignUp), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump();
      expect(find.text(AppStrings.fieldRequired), findsWidgets);
    });

    testWidgets('calls signIn and shows error snackbar on failure', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump(); // start async
      await tester.pump(); // settle auth state
      expect(find.text(AppStrings.authError), findsOneWidget);
    });
  });
}
