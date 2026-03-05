import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';

/// Contract for all goal data operations.
///
/// The domain layer only knows about this interface.
/// The data layer provides the implementation (GoalRepositoryImpl).
/// This inversion is what makes the domain testable without a real database.
abstract class IGoalRepository {
  /// Returns all goals for the current user, ordered by priority.
  Future<Either<Failure, List<Goal>>> getGoals();

  /// Persists a new goal. The [goal] object must have a pre-generated id.
  Future<Either<Failure, Goal>> createGoal(Goal goal);

  /// Replaces the stored goal with the updated version.
  Future<Either<Failure, Goal>> updateGoal(Goal goal);

  /// Soft-deletes by setting status to [GoalStatus.archived].
  /// Never hard-deletes — history must be preserved.
  Future<Either<Failure, Unit>> archiveGoal(String id);
}
