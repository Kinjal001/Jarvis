import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';

class GetCurrentUser {
  final IAuthRepository _repository;
  const GetCurrentUser(this._repository);

  Future<Either<Failure, AppUser?>> call() => _repository.getCurrentUser();
}
