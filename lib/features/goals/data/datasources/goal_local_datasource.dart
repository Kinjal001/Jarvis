import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';

/// Drift queries for the goals table.
///
/// Never used directly by use cases — only by [GoalRepositoryImpl].
class GoalLocalDatasource {
  final AppDatabase _db;
  const GoalLocalDatasource(this._db);

  Future<List<GoalRow>> getAll() => _db.select(_db.goalsTable).get();

  Future<void> upsert(GoalsTableCompanion companion) =>
      _db.into(_db.goalsTable).insertOnConflictUpdate(companion);

  Future<void> updateStatus(String id, String status) =>
      (_db.update(_db.goalsTable)..where((t) => t.id.equals(id))).write(
        GoalsTableCompanion(
          status: Value(status),
          syncStatus: const Value('pendingUpload'),
        ),
      );

  Future<void> markSynced(String id) =>
      (_db.update(_db.goalsTable)..where((t) => t.id.equals(id))).write(
        const GoalsTableCompanion(syncStatus: Value('synced')),
      );
}
