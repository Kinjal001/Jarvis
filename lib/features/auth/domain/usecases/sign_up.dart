import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';

class SignUp {
  final IAuthRepository _repository;
  const SignUp(this._repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) => _repository.signUp(email: email, password: password);
}
