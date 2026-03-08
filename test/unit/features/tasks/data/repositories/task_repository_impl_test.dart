import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:jarvis/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:jarvis/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskLocalDatasource extends Mock implements TaskLocalDatasource {}

class MockTaskRemoteDatasource extends Mock implements TaskRemoteDatasource {}

Task _makeTask({String id = 't1', DateTime? dueDate}) => Task(
  id: id,
  userId: 'u1',
  title: 'Buy groceries',
  priority: 2,
  status: TaskStatus.pending,
  isRecurring: false,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  dueDate: dueDate,
);

TaskRow _makeRow({String id = 't1', DateTime? dueDate}) => TaskRow(
  id: id,
  userId: 'u1',
  title: 'Buy groceries',
  description: null,
  dueDate: dueDate,
  priority: 2,
  status: 'pending',
  isRecurring: false,
  recurrenceRule: null,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  syncStatus: 'synced',
);

void main() {
  late MockTaskLocalDatasource local;
  late MockTaskRemoteDatasource remote;
  late TaskRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_makeTask());
    registerFallbackValue(TaskStatus.pending);
    registerFallbackValue(const TasksTableCompanion());
  });

  setUp(() {
    local = MockTaskLocalDatasource();
    remote = MockTaskRemoteDatasource();
    repo = TaskRepositoryImpl(local, remote);
  });

  group('getTasks', () {
    test('returns mapped list from local', () async {
      when(
        () => local.getAll(),
      ).thenAnswer((_) async => [_makeRow(), _makeRow(id: 't2')]);

      final result = await repo.getTasks();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 2);
    });

    test('returns failure when local throws', () async {
      when(() => local.getAll()).thenThrow(Exception('db error'));

      final result = await repo.getTasks();

      expect(
        result,
        const Left(Failure.database(message: 'Failed to load tasks')),
      );
    });
  });

  group('getTasksDueToday', () {
    test('returns tasks from getDueToday datasource method', () async {
      final today = DateTime.now();
      when(
        () => local.getDueToday(),
      ).thenAnswer((_) async => [_makeRow(dueDate: today)]);

      final result = await repo.getTasksDueToday();

      expect(result.isRight(), true);
      verify(() => local.getDueToday()).called(1);
    });
  });

  group('createTask', () {
    test('writes locally and returns the task', () async {
      final task = _makeTask();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repo.createTask(task);

      expect(result, Right(task));
      verify(() => local.upsert(any())).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.createTask(_makeTask()),
        const Left(Failure.database(message: 'Failed to create task')),
      );
    });
  });

  group('updateTaskStatus', () {
    test('calls updateStatus with correct args and returns unit', () async {
      when(
        () => local.updateStatus('t1', 'completed'),
      ).thenAnswer((_) async {});

      final result = await repo.updateTaskStatus('t1', TaskStatus.completed);

      expect(result, const Right(unit));
      verify(() => local.updateStatus('t1', 'completed')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.updateStatus(any(), any())).thenThrow(Exception('err'));

      expect(
        await repo.updateTaskStatus('t1', TaskStatus.skipped),
        const Left(Failure.database(message: 'Failed to update task status')),
      );
    });
  });
}
