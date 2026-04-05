import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:drift_flutter/drift_flutter.dart';

import 'package:jarvis/core/database/tables/goals_table.dart';
import 'package:jarvis/core/database/tables/habit_completions_table.dart';
import 'package:jarvis/core/database/tables/habits_table.dart';
import 'package:jarvis/core/database/tables/projects_table.dart';
import 'package:jarvis/core/database/tables/subtasks_table.dart';
import 'package:jarvis/core/database/tables/tasks_table.dart';

part 'app_database.g.dart';

/// The local SQLite database — the single source of truth for offline data.
///
/// Powered by Drift (type-safe SQLite wrapper).
///
/// Schema version history:
///   v1 (Phase 0) — empty schema, infrastructure only
///   v2 (Phase 1) — goals, projects, subtasks, tasks tables
///   v3 (Phase 2) — habits, habit_completions tables
///
/// NEVER drop tables. Add columns with a migration and a default value.
/// Schema version must be bumped whenever the schema changes.
@DriftDatabase(
  tables: [
    GoalsTable,
    ProjectsTable,
    SubtasksTable,
    TasksTable,
    HabitsTable,
    HabitCompletionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(goalsTable);
        await m.createTable(projectsTable);
        await m.createTable(subtasksTable);
        await m.createTable(tasksTable);
      }
      if (from < 3) {
        await m.createTable(habitsTable);
        await m.createTable(habitCompletionsTable);
      }
    },
  );

  static QueryExecutor _openConnection() {
    if (kIsWeb) {
      return driftDatabase(
        name: 'jarvis_db',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
    }
    return driftDatabase(name: 'jarvis_db');
  }
}
