import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';

class TaskLocalDatasource {
  final AppDatabase _db;
  const TaskLocalDatasource(this._db);

  Future<List<TaskRow>> getAll() => _db.select(_db.tasksTable).get();

  /// Returns pending tasks whose [dueDate] falls within today (midnight to 23:59:59).
  Future<List<TaskRow>> getDueToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return (_db.select(_db.tasksTable)..where(
          (t) =>
              t.dueDate.isBiggerOrEqualValue(startOfDay) &
              t.dueDate.isSmallerOrEqualValue(endOfDay) &
              t.status.equals('pending'),
        ))
        .get();
  }

  Future<void> upsert(TasksTableCompanion companion) =>
      _db.into(_db.tasksTable).insertOnConflictUpdate(companion);

  Future<void> updateStatus(String id, String status) =>
      (_db.update(_db.tasksTable)..where((t) => t.id.equals(id))).write(
        TasksTableCompanion(
          status: Value(status),
          syncStatus: const Value('pendingUpload'),
        ),
      );

  Future<void> markSynced(String id) =>
      (_db.update(_db.tasksTable)..where((t) => t.id.equals(id))).write(
        const TasksTableCompanion(syncStatus: Value('synced')),
      );
}
