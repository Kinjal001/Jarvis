import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/features/habits/data/datasources/habit_local_datasource.dart';
import 'package:jarvis/features/habits/data/datasources/habit_remote_datasource.dart';
import 'package:jarvis/features/habits/data/models/habit_completion_model.dart';
import 'package:jarvis/features/habits/data/models/habit_model.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/repositories/i_habit_repository.dart';

class HabitRepositoryImpl implements IHabitRepository {
  final HabitLocalDatasource _local;
  final HabitRemoteDatasource _remote;

  const HabitRepositoryImpl(this._local, this._remote);

  @override
  Future<Either<Failure, List<Habit>>> getHabits() async {
    try {
      final rows = await _local.getAll();
      return Right(rows.map(HabitModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to load habits'));
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    try {
      await _local.upsert(HabitModel.toCompanion(habit));
      unawaited(_pushHabitToRemote(habit));
      return Right(habit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to create habit'));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    try {
      await _local.upsert(HabitModel.toCompanion(habit));
      unawaited(_pushHabitToRemote(habit));
      return Right(habit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to update habit'));
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveHabit(String id) async {
    try {
      await _local.archive(id);
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to archive habit'));
    }
  }

  @override
  Future<Either<Failure, HabitCompletion>> logCompletion(
    HabitCompletion completion,
  ) async {
    try {
      await _local.upsertCompletion(
        HabitCompletionModel.toCompanion(completion),
      );
      unawaited(_pushCompletionToRemote(completion));
      return Right(completion);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(Failure.database(message: 'Failed to log completion'));
    }
  }

  @override
  Future<Either<Failure, List<HabitCompletion>>> getCompletions(
    String habitId,
  ) async {
    try {
      final rows = await _local.getCompletionsByHabitId(habitId);
      return Right(rows.map(HabitCompletionModel.fromRow).toList());
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to load completions'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCompletion(String id) async {
    try {
      await _local.deleteCompletion(id);
      unawaited(_remote.deleteCompletion(id));
      return const Right(unit);
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
      return const Left(
        Failure.database(message: 'Failed to delete completion'),
      );
    }
  }

  // ── Private sync helpers ──────────────────────────────────────────────────

  Future<void> _pushHabitToRemote(Habit habit) async {
    try {
      await _remote.upsertHabit(HabitModel.toRemoteMap(habit));
      await _local.markSynced(habit.id);
    } catch (_) {}
  }

  Future<void> _pushCompletionToRemote(HabitCompletion completion) async {
    try {
      await _remote.upsertCompletion(
        HabitCompletionModel.toRemoteMap(completion),
      );
      await _local.markCompletionSynced(completion.id);
    } catch (_) {}
  }
}
