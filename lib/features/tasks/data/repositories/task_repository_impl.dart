import 'dart:async';

import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:jarvis/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:jarvis/features/tasks/data/models/task_model.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskLocalDatasource _local;
  final TaskRemoteDatasource _remote;

  const TaskRepositoryImpl(this._local, this._remote);

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final rows = await _local.getAll();
      return Right(rows.map(TaskModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to load tasks'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksDueToday() async {
    try {
      final rows = await _local.getDueToday();
      return Right(rows.map(TaskModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to load tasks due today'),
      );
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      await _local.upsert(TaskModel.toCompanion(task));
      unawaited(_pushToRemote(task));
      return Right(task);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to create task'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTaskStatus(
    String id,
    TaskStatus status,
  ) async {
    try {
      await _local.updateStatus(id, status.name);
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to update task status'),
      );
    }
  }

  Future<void> _pushToRemote(Task task) async {
    try {
      await _remote.upsert(TaskModel.toRemoteMap(task));
      await _local.markSynced(task.id);
    } catch (_) {}
  }
}
