import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';

class CreateTask {
  final ITaskRepository _repository;
  const CreateTask(this._repository);

  Future<Either<Failure, Task>> call(Task task) => _repository.createTask(task);
}
