import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';
import 'package:jarvis/features/projects/presentation/providers/project_providers.dart';

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

class _FakeProjectRepository implements IProjectRepository {
  final List<Project> _projects;
  _FakeProjectRepository([this._projects = const []]);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async =>
      Right(_projects);

  @override
  Future<Either<Failure, List<Project>>> getProjectsByGoal(
    String goalId,
  ) async => Right(_projects);

  @override
  Future<Either<Failure, Project>> createProject(Project project) async =>
      Right(project);

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async =>
      Right(project);

  @override
  Future<Either<Failure, Unit>> archiveProject(String id) async =>
      const Right(unit);
}

Widget _buildTestApp({
  required String goalId,
  List<Goal> goals = const [],
  List<Project> projects = const [],
}) {
  return ProviderScope(
    overrides: [
      goalRepositoryProvider.overrideWith((ref) => _FakeGoalRepository(goals)),
      projectRepositoryProvider.overrideWith(
        (ref) => _FakeProjectRepository(projects),
      ),
    ],
    child: MaterialApp(home: GoalDetailScreen(goalId: goalId)),
  );
}

void main() {
  final now = DateTime.now();

  final goal = Goal(
    id: 'g1',
    userId: 'u1',
    title: 'Learn ML',
    intention: 'Career change',
    priority: 2,
    status: GoalStatus.active,
    createdAt: now,
    updatedAt: now,
  );

  group('GoalDetailScreen', () {
    testWidgets('renders goal title in AppBar', (tester) async {
      await tester.pumpWidget(_buildTestApp(goalId: 'g1', goals: [goal]));
      await tester.pump();
      expect(find.text('Learn ML'), findsWidgets);
    });

    testWidgets('shows no projects empty state', (tester) async {
      await tester.pumpWidget(_buildTestApp(goalId: 'g1', goals: [goal]));
      await tester.pump();
      expect(find.text(AppStrings.noProjectsYet), findsOneWidget);
    });

    testWidgets('shows projects list', (tester) async {
      final project = Project(
        id: 'p1',
        userId: 'u1',
        goalId: 'g1',
        title: 'Build CNN model',
        priority: 1,
        status: ProjectStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      await tester.pumpWidget(
        _buildTestApp(goalId: 'g1', goals: [goal], projects: [project]),
      );
      await tester.pump();
      expect(find.text('Build CNN model'), findsOneWidget);
    });

    testWidgets('shows add project FAB', (tester) async {
      await tester.pumpWidget(_buildTestApp(goalId: 'g1', goals: [goal]));
      await tester.pump();
      expect(find.byKey(const Key('add_project_fab')), findsOneWidget);
    });
  });
}
