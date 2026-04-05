import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';

class HabitLocalDatasource {
  final AppDatabase _db;
  const HabitLocalDatasource(this._db);

  // ── Habits ────────────────────────────────────────────────────────────────

  Future<List<HabitRow>> getAll() => _db.select(_db.habitsTable).get();

  Future<void> upsert(HabitsTableCompanion companion) =>
      _db.into(_db.habitsTable).insertOnConflictUpdate(companion);

  Future<void> archive(String id) =>
      (_db.update(_db.habitsTable)..where((t) => t.id.equals(id))).write(
        const HabitsTableCompanion(
          isActive: Value(false),
          syncStatus: Value('pendingUpload'),
        ),
      );

  Future<void> markSynced(String id) =>
      (_db.update(_db.habitsTable)..where((t) => t.id.equals(id))).write(
        const HabitsTableCompanion(syncStatus: Value('synced')),
      );

  // ── Completions ───────────────────────────────────────────────────────────

  /// Returns all completions for [habitId], newest first.
  Future<List<HabitCompletionRow>> getCompletionsByHabitId(String habitId) =>
      (_db.select(_db.habitCompletionsTable)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .get();

  Future<void> upsertCompletion(HabitCompletionsTableCompanion companion) =>
      _db.into(_db.habitCompletionsTable).insertOnConflictUpdate(companion);

  Future<void> deleteCompletion(String id) => (_db.delete(
    _db.habitCompletionsTable,
  )..where((t) => t.id.equals(id))).go();

  Future<void> markCompletionSynced(String id) =>
      (_db.update(
        _db.habitCompletionsTable,
      )..where((t) => t.id.equals(id))).write(
        const HabitCompletionsTableCompanion(syncStatus: Value('synced')),
      );
}
