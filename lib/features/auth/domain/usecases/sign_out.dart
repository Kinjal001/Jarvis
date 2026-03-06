import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';

class SignOut {
  final IAuthRepository _repository;
  const SignOut(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.signOut();
}
