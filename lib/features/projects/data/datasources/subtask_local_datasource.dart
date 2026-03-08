import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';

class SubtaskLocalDatasource {
  final AppDatabase _db;
  const SubtaskLocalDatasource(this._db);

  Future<List<SubtaskRow>> getByProject(String projectId) =>
      (_db.select(_db.subtasksTable)
            ..where((t) => t.projectId.equals(projectId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<void> upsert(SubtasksTableCompanion companion) =>
      _db.into(_db.subtasksTable).insertOnConflictUpdate(companion);

  Future<void> updateStatus(String id, String status) =>
      (_db.update(_db.subtasksTable)..where((t) => t.id.equals(id))).write(
        SubtasksTableCompanion(
          status: Value(status),
          syncStatus: const Value('pendingUpload'),
        ),
      );

  Future<void> markSynced(String id) =>
      (_db.update(_db.subtasksTable)..where((t) => t.id.equals(id))).write(
        const SubtasksTableCompanion(syncStatus: Value('synced')),
      );
}
