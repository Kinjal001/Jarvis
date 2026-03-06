import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';

class UpdateGoal {
  final IGoalRepository _repository;
  const UpdateGoal(this._repository);

  Future<Either<Failure, Goal>> call(Goal goal) => _repository.updateGoal(goal);
}
