import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';

class ArchiveProject {
  final IProjectRepository _repository;
  const ArchiveProject(this._repository);

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.archiveProject(id);
}
