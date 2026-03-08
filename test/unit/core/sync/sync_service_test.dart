import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/sync/sync_remote_gateway.dart';
import 'package:jarvis/core/sync/sync_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncRemoteGateway extends Mock implements SyncRemoteGateway {}

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

// ── Goal helpers ──────────────────────────────────────────────────────────────

GoalsTableCompanion _goal({
  String id = 'goal-1',
  String userId = 'user-1',
  String syncStatus = 'pendingUpload',
  DateTime? updatedAt,
}) => GoalsTableCompanion(
  id: Value(id),
  userId: Value(userId),
  title: const Value('Learn Rust'),
  intention: const Value('Systems programming'),
  priority: const Value(2),
  status: const Value('active'),
  syncStatus: Value(syncStatus),
  createdAt: Value(updatedAt ?? DateTime(2024)),
  updatedAt: Value(updatedAt ?? DateTime(2024)),
);

// ── Project helpers ───────────────────────────────────────────────────────────

ProjectsTableCompanion _project({
  String id = 'proj-1',
  String userId = 'user-1',
  String syncStatus = 'pendingUpload',
}) => ProjectsTableCompanion(
  id: Value(id),
  userId: Value(userId),
  title: const Value('Rust book exercises'),
  priority: const Value(2),
  status: const Value('active'),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

// ── Subtask helpers ───────────────────────────────────────────────────────────

SubtasksTableCompanion _subtask({
  String id = 'sub-1',
  String projectId = 'proj-1',
  String syncStatus = 'pendingUpload',
}) => SubtasksTableCompanion(
  id: Value(id),
  projectId: Value(projectId),
  title: const Value('Chapter 1'),
  isRecurring: const Value(false),
  status: const Value('pending'),
  sortOrder: const Value(0),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

// ── Task helpers ──────────────────────────────────────────────────────────────

TasksTableCompanion _task({
  String id = 'task-1',
  String userId = 'user-1',
  String syncStatus = 'pendingUpload',
}) => TasksTableCompanion(
  id: Value(id),
  userId: Value(userId),
  title: const Value('Read chapter 3'),
  priority: const Value(2),
  status: const Value('pending'),
  isRecurring: const Value(false),
  syncStatus: Value(syncStatus),
  createdAt: Value(DateTime(2024)),
  updatedAt: Value(DateTime(2024)),
);

void main() {
  late AppDatabase db;
  late MockSyncRemoteGateway gateway;
  late SyncService service;

  setUp(() {
    db = _makeDb();
    gateway = MockSyncRemoteGateway();
    service = SyncService(db, gateway);

    // Default stubs — return empty lists for all pulls.
    when(
      () => gateway.fetchGoals(any(), since: any(named: 'since')),
    ).thenAnswer((_) async => []);
    when(
      () => gateway.fetchProjects(any(), since: any(named: 'since')),
    ).thenAnswer((_) async => []);
    when(
      () => gateway.fetchSubtasks(any(), since: any(named: 'since')),
    ).thenAnswer((_) async => []);
    when(
      () => gateway.fetchTasks(any(), since: any(named: 'since')),
    ).thenAnswer((_) async => []);
    when(() => gateway.upsertGoals(any())).thenAnswer((_) async {});
    when(() => gateway.upsertProjects(any())).thenAnswer((_) async {});
    when(() => gateway.upsertSubtasks(any())).thenAnswer((_) async {});
    when(() => gateway.upsertTasks(any())).thenAnswer((_) async {});
  });

  tearDown(() => db.close());

  // ── Push ───────────────────────────────────────────────────────────────────

  group('push — goals', () {
    test('upserts pending goals and marks them synced', () async {
      await db.into(db.goalsTable).insert(_goal());
      await service.sync('user-1');

      verify(() => gateway.upsertGoals(any())).called(1);

      final rows = await db.select(db.goalsTable).get();
      expect(rows.first.syncStatus, 'synced');
    });

    test('does not call upsertGoals when nothing is pending', () async {
      await db.into(db.goalsTable).insert(_goal(syncStatus: 'synced'));
      await service.sync('user-1');

      verifyNever(() => gateway.upsertGoals(any()));
    });

    test('swallows gateway error and leaves row as pendingUpload', () async {
      await db.into(db.goalsTable).insert(_goal());
      when(() => gateway.upsertGoals(any())).thenThrow(Exception('network'));

      // Should not throw.
      await expectLater(service.sync('user-1'), completes);

      final rows = await db.select(db.goalsTable).get();
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('push — projects', () {
    test('upserts pending projects and marks them synced', () async {
      await db.into(db.projectsTable).insert(_project());
      await service.sync('user-1');

      verify(() => gateway.upsertProjects(any())).called(1);

      final rows = await db.select(db.projectsTable).get();
      expect(rows.first.syncStatus, 'synced');
    });

    test('swallows gateway error and leaves row as pendingUpload', () async {
      await db.into(db.projectsTable).insert(_project());
      when(() => gateway.upsertProjects(any())).thenThrow(Exception('network'));

      await expectLater(service.sync('user-1'), completes);

      final rows = await db.select(db.projectsTable).get();
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  group('push — subtasks', () {
    test('upserts pending subtasks and marks them synced', () async {
      await db.into(db.subtasksTable).insert(_subtask());
      await service.sync('user-1');

      verify(() => gateway.upsertSubtasks(any())).called(1);

      final rows = await db.select(db.subtasksTable).get();
      expect(rows.first.syncStatus, 'synced');
    });
  });

  group('push — tasks', () {
    test('upserts pending tasks and marks them synced', () async {
      await db.into(db.tasksTable).insert(_task());
      await service.sync('user-1');

      verify(() => gateway.upsertTasks(any())).called(1);

      final rows = await db.select(db.tasksTable).get();
      expect(rows.first.syncStatus, 'synced');
    });

    test('swallows gateway error and leaves row as pendingUpload', () async {
      await db.into(db.tasksTable).insert(_task());
      when(() => gateway.upsertTasks(any())).thenThrow(Exception('network'));

      await expectLater(service.sync('user-1'), completes);

      final rows = await db.select(db.tasksTable).get();
      expect(rows.first.syncStatus, 'pendingUpload');
    });
  });

  // ── Pull ───────────────────────────────────────────────────────────────────

  group('pull — goals', () {
    test('fetches without since when no local rows exist', () async {
      await service.sync('user-1');

      final captured = verify(
        () => gateway.fetchGoals('user-1', since: captureAny(named: 'since')),
      ).captured;
      expect(captured.first, equals(null));
    });

    test('fetches with since equal to max local updatedAt', () async {
      final ts = DateTime(2025, 6, 1);
      await db
          .into(db.goalsTable)
          .insert(_goal(userId: 'user-1', updatedAt: ts));
      await service.sync('user-1');

      final captured = verify(
        () => gateway.fetchGoals('user-1', since: captureAny(named: 'since')),
      ).captured;
      expect(captured.first, ts);
    });

    test('upserts remote rows into local DB as synced', () async {
      when(
        () => gateway.fetchGoals(any(), since: any(named: 'since')),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'remote-goal-1',
            'user_id': 'user-1',
            'title': 'Remote Goal',
            'intention': 'Test pull',
            'deadline': null,
            'priority': 3,
            'status': 'active',
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          },
        ],
      );

      await service.sync('user-1');

      final rows = await db.select(db.goalsTable).get();
      expect(rows.length, 1);
      expect(rows.first.id, 'remote-goal-1');
      expect(rows.first.syncStatus, 'synced');
    });

    test('pull error is swallowed', () async {
      when(
        () => gateway.fetchGoals(any(), since: any(named: 'since')),
      ).thenThrow(Exception('network'));

      await expectLater(service.sync('user-1'), completes);
    });
  });

  group('pull — subtasks', () {
    test('skips fetch when user has no local projects', () async {
      await service.sync('user-1');

      verifyNever(
        () => gateway.fetchSubtasks(any(), since: any(named: 'since')),
      );
    });

    test('fetches subtasks using local project IDs', () async {
      await db.into(db.projectsTable).insert(_project(syncStatus: 'synced'));
      await service.sync('user-1');

      final captured = verify(
        () => gateway.fetchSubtasks(captureAny(), since: any(named: 'since')),
      ).captured;
      expect(captured.first, contains('proj-1'));
    });

    test('upserts remote subtasks as synced', () async {
      await db.into(db.projectsTable).insert(_project(syncStatus: 'synced'));
      when(
        () => gateway.fetchSubtasks(any(), since: any(named: 'since')),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'remote-sub-1',
            'project_id': 'proj-1',
            'title': 'Remote Subtask',
            'description': null,
            'deadline': null,
            'is_recurring': false,
            'recurrence_rule': null,
            'status': 'pending',
            'sort_order': 0,
            'created_at': '2025-01-01T00:00:00.000Z',
            'updated_at': '2025-01-01T00:00:00.000Z',
          },
        ],
      );

      await service.sync('user-1');

      final rows = await db.select(db.subtasksTable).get();
      expect(rows.length, 1);
      expect(rows.first.id, 'remote-sub-1');
      expect(rows.first.syncStatus, 'synced');
    });
  });
}
