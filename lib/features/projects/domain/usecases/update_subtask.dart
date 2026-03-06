import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';

class UpdateSubtask {
  final ISubtaskRepository _repository;
  const UpdateSubtask(this._repository);

  Future<Either<Failure, Subtask>> call(Subtask subtask) =>
      _repository.updateSubtask(subtask);
}
