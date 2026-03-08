import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_local_datasource.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

SubtasksTableCompanion _makeCompanion({
  String id = 's1',
  String projectId = 'p1',
  int sortOrder = 0,
  String syncStatus = 'pendingUpload',
}) => SubtasksTableCompanion(
  id: Value(id),
  projectId: Value(projectId),
  title: const Value('Watch lesson 1'),
  isRecurring: const Value(false),
  status: const Value('pending'),
  sortOrder: Value(sortOrder),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

void main() {
  late AppDatabase db;
  late SubtaskLocalDatasource datasource;

  setUp(() {
    db = _makeDb();
    datasource = SubtaskLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getByProject', () {
    test('returns empty list when no rows exist', () async {
      expect(await datasource.getByProject('p1'), isEmpty);
    });

    test('returns only subtasks for the given projectId', () async {
      await datasource.upsert(_makeCompanion(id: 's1', projectId: 'p1'));
      await datasource.upsert(_makeCompanion(id: 's2', projectId: 'p2'));
      await datasource.upsert(_makeCompanion(id: 's3', projectId: 'p1'));

      final rows = await datasource.getByProject('p1');
      expect(rows.length, 2);
      expect(rows.map((r) => r.id), containsAll(['s1', 's3']));
    });

    test('returns subtasks sorted by sortOrder ascending', () async {
      await datasource.upsert(_makeCompanion(id: 's1', sortOrder: 2));
      await datasource.upsert(_makeCompanion(id: 's2', sortOrder: 0));
      await datasource.upsert(_makeCompanion(id: 's3', sortOrder: 1));

      final rows = await datasource.getByProject('p1');
      expect(rows.map((r) => r.sortOrder).toList(), [0, 1, 2]);
    });
  });

  group('upsert', () {
    test('inserts a new row', () async {
      await datasource.upsert(_makeCompanion());

      final rows = await datasource.getByProject('p1');
      expect(rows.length, 1);
      expect(rows.first.id, 's1');
    });

    test('updates existing row on conflict', () async {
      await datasource.upsert(_makeCompanion());
      await datasource.upsert(
        _makeCompanion().copyWith(title: const Value('Updated lesson')),
      );

      final rows = await datasource.getByProject('p1');
      expect(rows.length, 1);
      expect(rows.first.title, 'Updated lesson');
    });
  });

  group('updateStatus', () {
    test('writes new status and marks pendingUpload', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'synced'));

      await datasource.updateStatus('s1', 'completed');

      final rows = await datasource.getByProject('p1');
      expect(rows.first.status, 'completed');
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('markSynced', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'pendingUpload'));

      await datasource.markSynced('s1');

      final rows = await datasource.getByProject('p1');
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
