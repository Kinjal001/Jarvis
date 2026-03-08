import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/goals/data/datasources/goal_local_datasource.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

GoalsTableCompanion _makeCompanion({
  String id = 'g1',
  String syncStatus = 'pendingUpload',
}) => GoalsTableCompanion(
  id: Value(id),
  userId: const Value('u1'),
  title: const Value('Learn ML'),
  intention: const Value('Career change'),
  priority: const Value(1),
  status: const Value('active'),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

void main() {
  late AppDatabase db;
  late GoalLocalDatasource datasource;

  setUp(() {
    db = _makeDb();
    datasource = GoalLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getAll', () {
    test('returns empty list when no rows exist', () async {
      expect(await datasource.getAll(), isEmpty);
    });

    test('returns all inserted rows', () async {
      await datasource.upsert(_makeCompanion(id: 'g1'));
      await datasource.upsert(_makeCompanion(id: 'g2'));

      final rows = await datasource.getAll();
      expect(rows.length, 2);
      expect(rows.map((r) => r.id), containsAll(['g1', 'g2']));
    });
  });

  group('upsert', () {
    test('inserts a new row', () async {
      await datasource.upsert(_makeCompanion());

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.id, 'g1');
    });

    test('updates existing row on conflict', () async {
      await datasource.upsert(_makeCompanion());
      await datasource.upsert(
        _makeCompanion().copyWith(title: const Value('Updated Title')),
      );

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.title, 'Updated Title');
    });
  });

  group('updateStatus', () {
    test('writes new status and marks pendingUpload', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'synced'));

      await datasource.updateStatus('g1', 'archived');

      final rows = await datasource.getAll();
      expect(rows.first.status, 'archived');
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('markSynced', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'pendingUpload'));

      await datasource.markSynced('g1');

      final rows = await datasource.getAll();
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
