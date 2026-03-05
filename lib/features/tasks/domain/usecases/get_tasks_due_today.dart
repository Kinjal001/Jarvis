import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';

class GetTasksDueToday {
  final ITaskRepository _repository;
  const GetTasksDueToday(this._repository);

  Future<Either<Failure, List<Task>>> call() => _repository.getTasksDueToday();
}
