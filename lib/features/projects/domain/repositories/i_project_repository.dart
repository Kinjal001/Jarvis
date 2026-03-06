import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';

abstract class IProjectRepository {
  /// Returns all active projects for the current user.
  Future<Either<Failure, List<Project>>> getProjects();

  /// Returns only projects that belong to the given goal.
  Future<Either<Failure, List<Project>>> getProjectsByGoal(String goalId);

  Future<Either<Failure, Project>> createProject(Project project);

  Future<Either<Failure, Project>> updateProject(Project project);

  /// Soft-deletes by setting status to [ProjectStatus.archived].
  Future<Either<Failure, Unit>> archiveProject(String id);
}
