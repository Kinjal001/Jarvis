import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';

class GetProjects {
  final IProjectRepository _repository;
  const GetProjects(this._repository);

  Future<Either<Failure, List<Project>>> call() => _repository.getProjects();
}
