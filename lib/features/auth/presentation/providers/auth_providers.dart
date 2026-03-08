import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jarvis/core/supabase/supabase_provider.dart';
import 'package:jarvis/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:jarvis/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_in.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_out.dart';
import 'package:jarvis/features/auth/domain/usecases/sign_up.dart';

part 'auth_providers.g.dart';

// ── Datasource ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(ref.watch(supabaseClientProvider));
}

// ── Repository ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
}

// ── Use cases ────────────────────────────────────────────────────────────────

@riverpod
SignIn signIn(Ref ref) => SignIn(ref.watch(authRepositoryProvider));

@riverpod
SignUp signUp(Ref ref) => SignUp(ref.watch(authRepositoryProvider));

@riverpod
SignOut signOut(Ref ref) => SignOut(ref.watch(authRepositoryProvider));

// ── Auth state stream ─────────────────────────────────────────────────────────

/// Exposes Supabase's auth state as a Dart stream.
///
/// `keepAlive: true` so the stream subscription lives for the full app
/// session; go_router's redirect listens to this indirectly via
/// [routerNotifierProvider].
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

// ── Action notifier ───────────────────────────────────────────────────────────

/// Handles sign-in, sign-up, and sign-out mutations.
///
/// State is `AsyncValue<void>` — null means idle/success, loading means in
/// flight, error carries the Failure.  The router handles navigation
/// automatically via [authStateChangesProvider].
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInProvider)
        .call(email: email, password: password);
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signUpProvider)
        .call(email: email, password: password);
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(signOutProvider).call();
    state = const AsyncData(null);
  }
}
