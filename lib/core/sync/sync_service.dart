import 'dart:async';

import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/error/sentry_service.dart';
import 'package:jarvis/core/sync/sync_remote_gateway.dart';
import 'package:jarvis/features/goals/data/models/goal_model.dart';
import 'package:jarvis/features/projects/data/models/project_model.dart';
import 'package:jarvis/features/projects/data/models/subtask_model.dart';
import 'package:jarvis/features/tasks/data/models/task_model.dart';

/// Handles local-first synchronisation between Drift and Supabase.
///
/// Strategy:
///   - Push: all rows with [syncStatus] = 'pendingUpload' are upserted to
///     Supabase, then marked 'synced' locally.
///   - Pull: rows on Supabase newer than the local max [updatedAt] are
///     upserted into Drift with syncStatus 'synced'.
///     Conflict resolution: last-write-wins via updatedAt.
///
/// All errors are logged to Sentry and swallowed — sync is best-effort.
/// The app always reads from Drift and is fully functional offline.
class SyncService {
  final AppDatabase _db;
  final SyncRemoteGateway _gateway;

  const SyncService(this._db, this._gateway);

  /// Run a full push + pull cycle for [userId].
  Future<void> sync(String userId) async {
    await _push();
    await _pull(userId);
  }

  // ── Push ─────────────────────────────────────────────────────────────────

  Future<void> _push() async {
    await _pushGoals();
    await _pushProjects();
    await _pushSubtasks();
    await _pushTasks();
  }

  Future<void> _pushGoals() async {
    final rows = await (_db.select(
      _db.goalsTable,
    )..where((t) => t.syncStatus.equals('pendingUpload'))).get();
    if (rows.isEmpty) return;
    try {
      final maps = rows
          .map((r) => GoalModel.toRemoteMap(GoalModel.fromRow(r)))
          .toList();
      await _gateway.upsertGoals(maps);
      for (final row in rows) {
        await (_db.update(_db.goalsTable)..where((t) => t.id.equals(row.id)))
            .write(const GoalsTableCompanion(syncStatus: Value('synced')));
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pushProjects() async {
    final rows = await (_db.select(
      _db.projectsTable,
    )..where((t) => t.syncStatus.equals('pendingUpload'))).get();
    if (rows.isEmpty) return;
    try {
      final maps = rows
          .map((r) => ProjectModel.toRemoteMap(ProjectModel.fromRow(r)))
          .toList();
      await _gateway.upsertProjects(maps);
      for (final row in rows) {
        await (_db.update(_db.projectsTable)..where((t) => t.id.equals(row.id)))
            .write(const ProjectsTableCompanion(syncStatus: Value('synced')));
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pushSubtasks() async {
    final rows = await (_db.select(
      _db.subtasksTable,
    )..where((t) => t.syncStatus.equals('pendingUpload'))).get();
    if (rows.isEmpty) return;
    try {
      final maps = rows
          .map((r) => SubtaskModel.toRemoteMap(SubtaskModel.fromRow(r)))
          .toList();
      await _gateway.upsertSubtasks(maps);
      for (final row in rows) {
        await (_db.update(_db.subtasksTable)..where((t) => t.id.equals(row.id)))
            .write(const SubtasksTableCompanion(syncStatus: Value('synced')));
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pushTasks() async {
    final rows = await (_db.select(
      _db.tasksTable,
    )..where((t) => t.syncStatus.equals('pendingUpload'))).get();
    if (rows.isEmpty) return;
    try {
      final maps = rows
          .map((r) => TaskModel.toRemoteMap(TaskModel.fromRow(r)))
          .toList();
      await _gateway.upsertTasks(maps);
      for (final row in rows) {
        await (_db.update(_db.tasksTable)..where((t) => t.id.equals(row.id)))
            .write(const TasksTableCompanion(syncStatus: Value('synced')));
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  // ── Pull ─────────────────────────────────────────────────────────────────

  Future<void> _pull(String userId) async {
    await _pullGoals(userId);
    await _pullProjects(userId);
    await _pullTasks(userId);
    // Subtasks are pulled last so local project IDs are up to date.
    await _pullSubtasks(userId);
  }

  Future<void> _pullGoals(String userId) async {
    try {
      final since = await _maxGoalUpdatedAt(userId);
      final remote = await _gateway.fetchGoals(userId, since: since);
      for (final map in remote) {
        final goal = GoalModel.fromRemoteMap(map);
        await _db
            .into(_db.goalsTable)
            .insertOnConflictUpdate(
              GoalModel.toCompanion(goal, syncStatus: 'synced'),
            );
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pullProjects(String userId) async {
    try {
      final since = await _maxProjectUpdatedAt(userId);
      final remote = await _gateway.fetchProjects(userId, since: since);
      for (final map in remote) {
        final project = ProjectModel.fromRemoteMap(map);
        await _db
            .into(_db.projectsTable)
            .insertOnConflictUpdate(
              ProjectModel.toCompanion(project, syncStatus: 'synced'),
            );
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pullTasks(String userId) async {
    try {
      final since = await _maxTaskUpdatedAt(userId);
      final remote = await _gateway.fetchTasks(userId, since: since);
      for (final map in remote) {
        final task = TaskModel.fromRemoteMap(map);
        await _db
            .into(_db.tasksTable)
            .insertOnConflictUpdate(
              TaskModel.toCompanion(task, syncStatus: 'synced'),
            );
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  Future<void> _pullSubtasks(String userId) async {
    try {
      // Subtasks have no userId — scope by the user's local project IDs.
      final projectRows = await (_db.select(
        _db.projectsTable,
      )..where((t) => t.userId.equals(userId))).get();
      final projectIds = projectRows.map((r) => r.id).toList();
      if (projectIds.isEmpty) return;

      final since = await _maxSubtaskUpdatedAt(projectIds);
      final remote = await _gateway.fetchSubtasks(projectIds, since: since);
      for (final map in remote) {
        final subtask = SubtaskModel.fromRemoteMap(map);
        await _db
            .into(_db.subtasksTable)
            .insertOnConflictUpdate(
              SubtaskModel.toCompanion(subtask, syncStatus: 'synced'),
            );
      }
    } catch (e, st) {
      unawaited(SentryService.captureException(e, stackTrace: st));
    }
  }

  // ── Max updatedAt helpers ─────────────────────────────────────────────────

  Future<DateTime?> _maxGoalUpdatedAt(String userId) async {
    final rows =
        await (_db.select(_db.goalsTable)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.updatedAt;
  }

  Future<DateTime?> _maxProjectUpdatedAt(String userId) async {
    final rows =
        await (_db.select(_db.projectsTable)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.updatedAt;
  }

  Future<DateTime?> _maxTaskUpdatedAt(String userId) async {
    final rows =
        await (_db.select(_db.tasksTable)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.updatedAt;
  }

  Future<DateTime?> _maxSubtaskUpdatedAt(List<String> projectIds) async {
    final rows =
        await (_db.select(_db.subtasksTable)
              ..where((t) => t.projectId.isIn(projectIds))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.updatedAt;
  }
}
