import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';

class UpdateProject {
  final IProjectRepository _repository;
  const UpdateProject(this._repository);

  Future<Either<Failure, Project>> call(Project project) =>
      _repository.updateProject(project);
}
