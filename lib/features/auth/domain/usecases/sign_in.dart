import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';

class SignIn {
  final IAuthRepository _repository;
  const SignIn(this._repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) => _repository.signIn(email: email, password: password);
}
