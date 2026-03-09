import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/home/presentation/screens/home_screen.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:jarvis/features/tasks/presentation/providers/task_providers.dart';

class _FakeGoalRepository implements IGoalRepository {
  final List<Goal> _goals;
  _FakeGoalRepository([this._goals = const []]);

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async => Right(_goals);

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async => Right(goal);

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async => Right(goal);

  @override
  Future<Either<Failure, Unit>> archiveGoal(String id) async =>
      const Right(unit);
}

class _FakeTaskRepository implements ITaskRepository {
  final List<Task> _tasks;
  _FakeTaskRepository([this._tasks = const []]);

  @override
  Future<Either<Failure, List<Task>>> getTasks() async => Right(_tasks);

  @override
  Future<Either<Failure, List<Task>>> getTasksDueToday() async => Right(_tasks);

  @override
  Future<Either<Failure, Task>> createTask(Task task) async => Right(task);

  @override
  Future<Either<Failure, Unit>> updateTaskStatus(
    String id,
    TaskStatus status,
  ) async => const Right(unit);
}

Widget _buildTestApp({
  List<Goal> goals = const [],
  List<Task> tasks = const [],
}) {
  return ProviderScope(
    overrides: [
      goalRepositoryProvider.overrideWith((ref) => _FakeGoalRepository(goals)),
      taskRepositoryProvider.overrideWith((ref) => _FakeTaskRepository(tasks)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders Due Today section heading', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text(AppStrings.dueToday), findsWidgets);
    });

    testWidgets('shows empty-state when no tasks are due today', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text(AppStrings.noTasksDueToday), findsOneWidget);
    });

    testWidgets('shows tasks due today', (tester) async {
      final now = DateTime.now();
      final task = Task(
        id: 't1',
        userId: 'u1',
        title: 'Test task',
        priority: 1,
        status: TaskStatus.pending,
        isRecurring: false,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await tester.pumpWidget(_buildTestApp(tasks: [task]));
      await tester.pump();
      expect(find.text('Test task'), findsOneWidget);
    });

    testWidgets('shows active goals', (tester) async {
      final now = DateTime.now();
      final goal = Goal(
        id: 'g1',
        userId: 'u1',
        title: 'Learn ML',
        intention: 'Career change',
        priority: 1,
        status: GoalStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      await tester.pumpWidget(_buildTestApp(goals: [goal]));
      await tester.pump();
      expect(find.text('Learn ML'), findsOneWidget);
    });

    testWidgets('shows no active goals message when goals list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text(AppStrings.noActiveGoals), findsOneWidget);
    });

    testWidgets('can toggle task checkbox to mark as done', (tester) async {
      final now = DateTime.now();
      final task = Task(
        id: 't1',
        userId: 'u1',
        title: 'Toggle me',
        priority: 1,
        status: TaskStatus.pending,
        isRecurring: false,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await tester.pumpWidget(_buildTestApp(tasks: [task]));
      await tester.pump();
      // Tap the checkbox — exercises _TodayTaskTile.onChanged + updateStatus
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
    });
  });
}
