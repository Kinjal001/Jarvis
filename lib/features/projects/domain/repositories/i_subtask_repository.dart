import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';

abstract class ISubtaskRepository {
  /// Returns all subtasks for a project, ordered by [sortOrder].
  Future<Either<Failure, List<Subtask>>> getSubtasksByProject(String projectId);

  Future<Either<Failure, Subtask>> createSubtask(Subtask subtask);

  /// Updates title, description, deadline, or other editable fields.
  Future<Either<Failure, Subtask>> updateSubtask(Subtask subtask);

  /// Changes only the status (pending/in_progress/completed/skipped).
  /// Separate from updateSubtask to make intent clear at call sites.
  Future<Either<Failure, Unit>> updateSubtaskStatus(
    String id,
    SubtaskStatus status,
  );
}
