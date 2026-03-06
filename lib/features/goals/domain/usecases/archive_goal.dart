import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';

class ArchiveGoal {
  final IGoalRepository _repository;
  const ArchiveGoal(this._repository);

  Future<Either<Failure, Unit>> call(String id) => _repository.archiveGoal(id);
}
