import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The local SQLite database — the single source of truth for offline data.
///
/// Powered by Drift (type-safe SQLite wrapper).
///
/// Schema starts empty in Phase 0. Tables are added one phase at a time:
/// - Phase 1: goals, projects, subtasks, tasks, tags
/// - Phase 2: habits, habit_logs, dailies, reminders
/// - Phase 4: time_blocks
///
/// NEVER drop tables. Add columns with a migration and a default value.
/// Schema version must be bumped whenever the schema changes.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  /// Opens a connection to the SQLite database file on disk.
  /// [driftDatabase] from drift_flutter handles the platform-specific path.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'jarvis_db');
  }
}
