import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';

class ProjectLocalDatasource {
  final AppDatabase _db;
  const ProjectLocalDatasource(this._db);

  Future<List<ProjectRow>> getAll() => _db.select(_db.projectsTable).get();

  Future<List<ProjectRow>> getByGoal(String goalId) => (_db.select(
    _db.projectsTable,
  )..where((t) => t.goalId.equals(goalId))).get();

  Future<void> upsert(ProjectsTableCompanion companion) =>
      _db.into(_db.projectsTable).insertOnConflictUpdate(companion);

  Future<void> updateStatus(String id, String status) =>
      (_db.update(_db.projectsTable)..where((t) => t.id.equals(id))).write(
        ProjectsTableCompanion(
          status: Value(status),
          syncStatus: const Value('pendingUpload'),
        ),
      );

  Future<void> markSynced(String id) =>
      (_db.update(_db.projectsTable)..where((t) => t.id.equals(id))).write(
        const ProjectsTableCompanion(syncStatus: Value('synced')),
      );
}
