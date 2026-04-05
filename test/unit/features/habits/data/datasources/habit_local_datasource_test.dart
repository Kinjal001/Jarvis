import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/habits/data/datasources/habit_local_datasource.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

HabitsTableCompanion _makeHabitCompanion({
  String id = 'h1',
  bool isActive = true,
  String syncStatus = 'pendingUpload',
}) => HabitsTableCompanion(
  id: Value(id),
  userId: const Value('u1'),
  title: const Value('Meditate'),
  frequency: const Value('daily'),
  targetDaysOfWeek: const Value(''),
  targetCount: const Value(1),
  colorHex: const Value('#7C3AED'),
  isActive: Value(isActive),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2025)),
  updatedAt: Value(DateTime(2025)),
);

HabitCompletionsTableCompanion _makeCompletionCompanion({
  String id = 'c1',
  String habitId = 'h1',
  DateTime? completedAt,
}) => HabitCompletionsTableCompanion(
  id: Value(id),
  habitId: Value(habitId),
  userId: const Value('u1'),
  completedAt: Value(completedAt ?? DateTime(2025, 1, 1, 12)),
  syncStatus: const Value('pendingUpload'),
);

void main() {
  late AppDatabase db;
  late HabitLocalDatasource datasource;

  setUp(() {
    db = _makeDb();
    datasource = HabitLocalDatasource(db);
  });

  tearDown(() => db.close());

  // ── Habits ─────────────────────────────────────────────────────────────────

  group('getAll', () {
    test('returns empty list when no rows exist', () async {
      expect(await datasource.getAll(), isEmpty);
    });

    test('returns all inserted habits', () async {
      await datasource.upsert(_makeHabitCompanion(id: 'h1'));
      await datasource.upsert(_makeHabitCompanion(id: 'h2'));

      expect((await datasource.getAll()).length, 2);
    });
  });

  group('upsert (habit)', () {
    test('inserts a new habit row', () async {
      await datasource.upsert(_makeHabitCompanion());

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.id, 'h1');
    });

    test('updates existing row on conflict', () async {
      await datasource.upsert(_makeHabitCompanion());
      await datasource.upsert(
        _makeHabitCompanion().copyWith(title: const Value('Exercise')),
      );

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.title, 'Exercise');
    });
  });

  group('archive', () {
    test('sets isActive to false and marks pendingUpload', () async {
      await datasource.upsert(_makeHabitCompanion(syncStatus: 'synced'));

      await datasource.archive('h1');

      final rows = await datasource.getAll();
      expect(rows.first.isActive, isFalse);
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('markSynced (habit)', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsert(_makeHabitCompanion(syncStatus: 'pendingUpload'));

      await datasource.markSynced('h1');

      final rows = await datasource.getAll();
      expect(rows.first.syncStatus, 'synced');
    });
  });

  // ── Completions ────────────────────────────────────────────────────────────

  group('getCompletionsByHabitId', () {
    test('returns empty when no completions exist', () async {
      expect(await datasource.getCompletionsByHabitId('h1'), isEmpty);
    });

    test('returns only completions for the given habitId', () async {
      await datasource.upsertCompletion(
        _makeCompletionCompanion(id: 'c1', habitId: 'h1'),
      );
      await datasource.upsertCompletion(
        _makeCompletionCompanion(id: 'c2', habitId: 'h2'),
      );

      final results = await datasource.getCompletionsByHabitId('h1');
      expect(results.length, 1);
      expect(results.first.id, 'c1');
    });

    test('returns results newest first', () async {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2025, 1, 3);

      await datasource.upsertCompletion(
        _makeCompletionCompanion(id: 'c1', completedAt: older),
      );
      await datasource.upsertCompletion(
        _makeCompletionCompanion(id: 'c2', completedAt: newer),
      );

      final results = await datasource.getCompletionsByHabitId('h1');
      expect(results.first.id, 'c2');
      expect(results.last.id, 'c1');
    });
  });

  group('upsertCompletion', () {
    test('inserts a completion row', () async {
      await datasource.upsertCompletion(_makeCompletionCompanion());

      final rows = await datasource.getCompletionsByHabitId('h1');
      expect(rows.length, 1);
      expect(rows.first.id, 'c1');
    });
  });

  group('deleteCompletion', () {
    test('removes the completion row', () async {
      await datasource.upsertCompletion(_makeCompletionCompanion(id: 'c1'));
      await datasource.upsertCompletion(_makeCompletionCompanion(id: 'c2'));

      await datasource.deleteCompletion('c1');

      final rows = await datasource.getCompletionsByHabitId('h1');
      expect(rows.length, 1);
      expect(rows.first.id, 'c2');
    });

    test('is a no-op when id does not exist', () async {
      await datasource.upsertCompletion(_makeCompletionCompanion(id: 'c1'));

      await datasource.deleteCompletion('nonexistent');

      expect((await datasource.getCompletionsByHabitId('h1')).length, 1);
    });
  });

  group('markCompletionSynced', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsertCompletion(_makeCompletionCompanion());

      await datasource.markCompletionSynced('c1');

      final rows = await datasource.getCompletionsByHabitId('h1');
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
