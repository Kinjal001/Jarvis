import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';

class UpdateTaskStatus {
  final ITaskRepository _repository;
  const UpdateTaskStatus(this._repository);

  Future<Either<Failure, Unit>> call(String id, TaskStatus status) =>
      _repository.updateTaskStatus(id, status);
}
