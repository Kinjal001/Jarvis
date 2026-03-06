import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';

class GetSubtasksByProject {
  final ISubtaskRepository _repository;
  const GetSubtasksByProject(this._repository);

  Future<Either<Failure, List<Subtask>>> call(String projectId) =>
      _repository.getSubtasksByProject(projectId);
}
