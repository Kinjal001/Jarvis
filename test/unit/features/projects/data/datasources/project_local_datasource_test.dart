import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/data/datasources/project_local_datasource.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

ProjectsTableCompanion _makeCompanion({
  String id = 'p1',
  String? goalId,
  String syncStatus = 'pendingUpload',
}) => ProjectsTableCompanion(
  id: Value(id),
  userId: const Value('u1'),
  goalId: Value(goalId),
  title: const Value('Complete Fast.ai'),
  priority: const Value(1),
  status: const Value('active'),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

void main() {
  late AppDatabase db;
  late ProjectLocalDatasource datasource;

  setUp(() {
    db = _makeDb();
    datasource = ProjectLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getAll', () {
    test('returns empty list when no rows exist', () async {
      expect(await datasource.getAll(), isEmpty);
    });

    test('returns all inserted rows', () async {
      await datasource.upsert(_makeCompanion(id: 'p1'));
      await datasource.upsert(_makeCompanion(id: 'p2'));

      expect((await datasource.getAll()).length, 2);
    });
  });

  group('getByGoal', () {
    test('returns only projects matching goalId', () async {
      await datasource.upsert(_makeCompanion(id: 'p1', goalId: 'g1'));
      await datasource.upsert(_makeCompanion(id: 'p2', goalId: 'g2'));
      await datasource.upsert(_makeCompanion(id: 'p3', goalId: 'g1'));

      final rows = await datasource.getByGoal('g1');
      expect(rows.length, 2);
      expect(rows.map((r) => r.id), containsAll(['p1', 'p3']));
    });

    test('returns empty list when no projects for goalId', () async {
      await datasource.upsert(_makeCompanion(id: 'p1', goalId: 'g2'));

      expect(await datasource.getByGoal('g1'), isEmpty);
    });
  });

  group('upsert', () {
    test('inserts a new row', () async {
      await datasource.upsert(_makeCompanion());

      final rows = await datasource.getAll();
      expect(rows.length, 1);
      expect(rows.first.id, 'p1');
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

      await datasource.updateStatus('p1', 'archived');

      final rows = await datasource.getAll();
      expect(rows.first.status, 'archived');
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('markSynced', () {
    test('sets syncStatus to synced', () async {
      await datasource.upsert(_makeCompanion(syncStatus: 'pendingUpload'));

      await datasource.markSynced('p1');

      final rows = await datasource.getAll();
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
