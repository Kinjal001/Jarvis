import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_remote_datasource.dart';
import 'package:jarvis/features/projects/data/models/subtask_model.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';

class SubtaskRepositoryImpl implements ISubtaskRepository {
  final SubtaskLocalDatasource _local;
  final SubtaskRemoteDatasource _remote;

  const SubtaskRepositoryImpl(this._local, this._remote);

  @override
  Future<Either<Failure, List<Subtask>>> getSubtasksByProject(
    String projectId,
  ) async {
    try {
      final rows = await _local.getByProject(projectId);
      return Right(rows.map(SubtaskModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to load subtasks'));
    }
  }

  @override
  Future<Either<Failure, Subtask>> createSubtask(Subtask subtask) async {
    try {
      await _local.upsert(SubtaskModel.toCompanion(subtask));
      unawaited(_pushToRemote(subtask));
      return Right(subtask);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to create subtask'));
    }
  }

  @override
  Future<Either<Failure, Subtask>> updateSubtask(Subtask subtask) async {
    try {
      await _local.upsert(SubtaskModel.toCompanion(subtask));
      unawaited(_pushToRemote(subtask));
      return Right(subtask);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to update subtask'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSubtaskStatus(
    String id,
    SubtaskStatus status,
  ) async {
    try {
      await _local.updateStatus(id, status.name);
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to update subtask status'),
      );
    }
  }

  Future<void> _pushToRemote(Subtask subtask) async {
    try {
      await _remote.upsert(SubtaskModel.toRemoteMap(subtask));
      await _local.markSynced(subtask.id);
    } catch (_) {}
  }
}
