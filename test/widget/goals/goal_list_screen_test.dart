import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_list_screen.dart';

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

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async => const Left(Failure.server(message: 'stub'));

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async => const Left(Failure.server(message: 'stub'));

  @override
  Future<Either<Failure, Unit>> signOut() async => const Right(unit);

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async => const Right(null);

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);
}

Widget _buildTestApp(List<Goal> goals) {
  return ProviderScope(
    overrides: [
      goalRepositoryProvider.overrideWith((ref) => _FakeGoalRepository(goals)),
      authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
    ],
    child: const MaterialApp(home: GoalListScreen()),
  );
}

Goal _makeGoal(String id, String title) {
  final now = DateTime.now();
  return Goal(
    id: id,
    userId: 'u1',
    title: title,
    intention: 'Some intention',
    priority: 1,
    status: GoalStatus.active,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('GoalListScreen', () {
    testWidgets('renders AppBar with goals title', (tester) async {
      await tester.pumpWidget(_buildTestApp([]));
      await tester.pump();
      expect(find.text(AppStrings.goals), findsWidgets);
    });

    testWidgets('shows empty state when no goals exist', (tester) async {
      await tester.pumpWidget(_buildTestApp([]));
      await tester.pump();
      expect(find.text(AppStrings.noGoalsYet), findsOneWidget);
    });

    testWidgets('shows add goal FAB', (tester) async {
      await tester.pumpWidget(_buildTestApp([]));
      await tester.pump();
      expect(find.byKey(const Key('add_goal_fab')), findsOneWidget);
    });

    testWidgets('shows goal titles in list', (tester) async {
      final goals = [
        _makeGoal('g1', 'Learn ML'),
        _makeGoal('g2', 'Build Jarvis'),
      ];
      await tester.pumpWidget(_buildTestApp(goals));
      await tester.pump();
      expect(find.text('Learn ML'), findsOneWidget);
      expect(find.text('Build Jarvis'), findsOneWidget);
    });

    // Sign-out was moved to the Profile tab in Phase 1.5 — no longer on this screen.
  });
}
