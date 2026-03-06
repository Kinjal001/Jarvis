import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';

abstract class ITaskRepository {
  /// Returns all tasks for the current user.
  Future<Either<Failure, List<Task>>> getTasks();

  /// Returns tasks where dueDate is today or earlier and status is pending.
  /// Used to populate the home screen's "Today" list.
  Future<Either<Failure, List<Task>>> getTasksDueToday();

  Future<Either<Failure, Task>> createTask(Task task);

  /// Changes only the status. The primary action for the home screen.
  Future<Either<Failure, Unit>> updateTaskStatus(String id, TaskStatus status);
}
