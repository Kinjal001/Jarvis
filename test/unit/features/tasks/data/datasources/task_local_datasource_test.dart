import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/tasks/data/datasources/task_local_datasource.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

TasksTableCompanion _makeCompanion({
  String id = 't1',
  String status = 'pending',
  DateTime? dueDate,
  String syncStatus = 'pendingUpload',
}) => TasksTableCompanion(
  id: Value(id),
  userId: const Value('u1'),
  title: const Value('Review notes'),
  priority: const Value(1),
  status: Value(status),
  isRecurring: const Value(false),
  dueDate: Value(dueDate),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

void main() {
  late AppDatabase db;
  late TaskLocalDatasource datasource;

  setUp(() {
    db = _makeDb();
    datasource = TaskLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getAll', () {
    test('returns empty list when no rows exist', () async {
      expect(await datasource.getAll(), isEmpty);
    });

    test('returns all inserted rows', () async {
      await datasource.upsert(_makeCompanion(id: 't1'));
      await datasource.upsert(_makeCompanion(id: 't2'));

      expect((await datasource.getAll()).length, 2);
    });
  });

  group('getDueToday', () {
    test('returns pending tasks due today', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12);
      await datasource.upsert(_makeCompanion(id: 't1', dueDate: today));

      final rows = await datasource.getDueToday();
      expect(rows.length, 1);
      expect(rows.first.id, 't1');
    });

    test('excludes tasks with no dueDate', () async {
      await datasource.upsert(_makeCompanion(id: 't1'));

      expect(await datasource.getDueToday(), isEmpty);
    });

    test('excludes tasks due on a different day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await datasource.upsert(_makeCompanion(id: 't1', dueDate: yesterday));

      expect(await datasource.getDueToday(), isEmpty);
    });

    test('excludes completed tasks due today', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 9);
      await datasource.upsert(
        _makeCompanion(id: 't1', dueDate: today, status: 'completed'),
      );

      expect(await datasource.getDueToday(), isEmpty);
    });
  });

  group('upsert', () {
    test('inserts a new row', () async {
      await datasource.upsert(_makeCompanion());

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.id, 't1');
    });

    test('updates existing row on conflict', () async {
      await datasource.upsert(_makeCompanion());
      await datasource.upsert(
        _makeCompanion().copyWith(title: const Value('Updated task')),
      );

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.title, 'Updated task');
    });
  });

  group('updateStatus', () {
    test('writes new status and marks pendingUpload', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'synced'));

      await datasource.updateStatus('t1', 'completed');

      final rows = await datasource.getAll();
      expect(rows.first.status, 'completed');
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('markSynced', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'pendingUpload'));

      await datasource.markSynced('t1');

      final rows = await datasource.getAll();
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
