import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:jarvis/features/tasks/domain/usecases/create_task.dart';
import 'package:jarvis/features/tasks/domain/usecases/get_tasks.dart';
import 'package:jarvis/features/tasks/domain/usecases/get_tasks_due_today.dart';
import 'package:jarvis/features/tasks/domain/usecases/update_task_status.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

Task _makeTask({String id = 't1', DateTime? dueDate}) => Task(
  id: id,
  userId: 'user-1',
  title: 'Buy groceries',
  priority: 2,
  status: TaskStatus.pending,
  isRecurring: false,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  dueDate: dueDate,
);

void main() {
  late MockTaskRepository repo;

  setUpAll(() {
    registerFallbackValue(_makeTask());
    registerFallbackValue(TaskStatus.pending);
  });
  setUp(() => repo = MockTaskRepository());

  group('CreateTask', () {
    test('returns created task', () async {
      final task = _makeTask();
      when(() => repo.createTask(task)).thenAnswer((_) async => Right(task));

      final result = await CreateTask(repo).call(task);

      expect(result, Right(task));
      verify(() => repo.createTask(task)).called(1);
    });

    test('returns failure on error', () async {
      const failure = Failure.database(message: 'error');
      when(
        () => repo.createTask(any()),
      ).thenAnswer((_) async => const Left(failure));

      expect(await CreateTask(repo).call(_makeTask()), const Left(failure));
    });
  });

  group('GetTasks', () {
    test('returns all tasks', () async {
      final tasks = [_makeTask(id: 't1'), _makeTask(id: 't2')];
      when(() => repo.getTasks()).thenAnswer((_) async => Right(tasks));

      expect(await GetTasks(repo).call(), Right(tasks));
    });
  });

  group('GetTasksDueToday', () {
    test('returns only tasks due today', () async {
      final today = DateTime.now();
      final dueTodayTasks = [_makeTask(dueDate: today)];
      when(
        () => repo.getTasksDueToday(),
      ).thenAnswer((_) async => Right(dueTodayTasks));

      final result = await GetTasksDueToday(repo).call();

      expect(result, Right(dueTodayTasks));
    });
  });

  group('UpdateTaskStatus', () {
    test('calls repository with correct id and status', () async {
      when(
        () => repo.updateTaskStatus('t1', TaskStatus.completed),
      ).thenAnswer((_) async => const Right(unit));

      final result = await UpdateTaskStatus(
        repo,
      ).call('t1', TaskStatus.completed);

      expect(result, const Right(unit));
      verify(() => repo.updateTaskStatus('t1', TaskStatus.completed)).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'update failed');
      when(
        () => repo.updateTaskStatus(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      expect(
        await UpdateTaskStatus(repo).call('t1', TaskStatus.skipped),
        const Left(failure),
      );
    });
  });
}
