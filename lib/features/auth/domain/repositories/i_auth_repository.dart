import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  /// Returns the currently signed-in user, or null if not authenticated.
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Emits the current user whenever auth state changes (sign in / sign out).
  /// The router listens to this to redirect between /login and /.
  Stream<AppUser?> get authStateChanges;
}
