import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';

class UpdateSubtaskStatus {
  final ISubtaskRepository _repository;
  const UpdateSubtaskStatus(this._repository);

  Future<Either<Failure, Unit>> call(String id, SubtaskStatus status) =>
      _repository.updateSubtaskStatus(id, status);
}
