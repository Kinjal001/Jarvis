import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';

class GetGoals {
  final IGoalRepository _repository;
  const GetGoals(this._repository);

  Future<Either<Failure, List<Goal>>> call() => _repository.getGoals();
}
