import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';

class CreateGoal {
  final IGoalRepository _repository;
  const CreateGoal(this._repository);

  Future<Either<Failure, Goal>> call(Goal goal) => _repository.createGoal(goal);
}
