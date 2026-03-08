import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/features/projects/data/datasources/project_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:jarvis/features/projects/data/models/project_model.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';

class ProjectRepositoryImpl implements IProjectRepository {
  final ProjectLocalDatasource _local;
  final ProjectRemoteDatasource _remote;

  const ProjectRepositoryImpl(this._local, this._remote);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final rows = await _local.getAll();
      return Right(rows.map(ProjectModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to load projects'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByGoal(
    String goalId,
  ) async {
    try {
      final rows = await _local.getByGoal(goalId);
      return Right(rows.map(ProjectModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to load projects for goal'),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      await _local.upsert(ProjectModel.toCompanion(project));
      unawaited(_pushToRemote(project));
      return Right(project);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to create project'));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      await _local.upsert(ProjectModel.toCompanion(project));
      unawaited(_pushToRemote(project));
      return Right(project);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to update project'));
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveProject(String id) async {
    try {
      await _local.updateStatus(id, ProjectStatus.archived.name);
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to archive project'));
    }
  }

  Future<void> _pushToRemote(Project project) async {
    try {
      await _remote.upsert(ProjectModel.toRemoteMap(project));
      await _local.markSynced(project.id);
    } catch (_) {}
  }
}
