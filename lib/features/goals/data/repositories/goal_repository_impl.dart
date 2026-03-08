import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:jarvis/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:jarvis/features/goals/data/models/goal_model.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';

class GoalRepositoryImpl implements IGoalRepository {
  final GoalLocalDatasource _local;
  final GoalRemoteDatasource _remote;

  const GoalRepositoryImpl(this._local, this._remote);

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final rows = await _local.getAll();
      return Right(rows.map(GoalModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to load goals'));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async {
    try {
      await _local.upsert(GoalModel.toCompanion(goal));
      unawaited(_pushToRemote(goal));
      return Right(goal);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to create goal'));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      await _local.upsert(GoalModel.toCompanion(goal));
      unawaited(_pushToRemote(goal));
      return Right(goal);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to update goal'));
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveGoal(String id) async {
    try {
      // Status-only change: mark pendingUpload locally; SyncService pushes later.
      await _local.updateStatus(id, GoalStatus.archived.name);
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to archive goal'));
    }
  }

  /// Best-effort immediate push to Supabase.
  /// Any failure is swallowed — the row stays 'pendingUpload' for SyncService.
  Future<void> _pushToRemote(Goal goal) async {
    try {
      await _remote.upsert(GoalModel.toRemoteMap(goal));
      await _local.markSynced(goal.id);
    } catch (_) {}
  }
}
