import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:jarvis/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:jarvis/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalLocalDatasource extends Mock implements GoalLocalDatasource {}

class MockGoalRemoteDatasource extends Mock implements GoalRemoteDatasource {}

Goal _makeGoal({String id = 'g1'}) => Goal(
  id: id,
  userId: 'u1',
  title: 'Learn ML',
  intention: 'Career change',
  priority: 1,
  status: GoalStatus.active,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

GoalRow _makeRow({String id = 'g1'}) => GoalRow(
  id: id,
  userId: 'u1',
  title: 'Learn ML',
  intention: 'Career change',
  deadline: null,
  priority: 1,
  status: 'active',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  syncStatus: 'synced',
);

void main() {
  late MockGoalLocalDatasource local;
  late MockGoalRemoteDatasource remote;
  late GoalRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_makeGoal());
    registerFallbackValue(const GoalsTableCompanion());
  });

  setUp(() {
    local = MockGoalLocalDatasource();
    remote = MockGoalRemoteDatasource();
    repo = GoalRepositoryImpl(local, remote);
  });

  group('getGoals', () {
    test('returns mapped list from local datasource', () async {
      final rows = [_makeRow(id: 'g1'), _makeRow(id: 'g2')];
      when(() => local.getAll()).thenAnswer((_) async => rows);

      final result = await repo.getGoals();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 2);
      verify(() => local.getAll()).called(1);
    });

    test('returns database failure when local throws', () async {
      when(() => local.getAll()).thenThrow(Exception('db error'));

      final result = await repo.getGoals();

      expect(
        result,
        const Left(Failure.database(message: 'Failed to load goals')),
      );
    });
  });

  group('createGoal', () {
    test('writes to local and returns the goal', () async {
      final goal = _makeGoal();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repo.createGoal(goal);

      expect(result, Right(goal));
      verify(() => local.upsert(any())).called(1);
    });

    test('returns failure when local write throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('write error'));

      final result = await repo.createGoal(_makeGoal());

      expect(
        result,
        const Left(Failure.database(message: 'Failed to create goal')),
      );
    });
  });

  group('updateGoal', () {
    test('writes updated goal to local and returns it', () async {
      final goal = _makeGoal();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repo.updateGoal(goal);

      expect(result, Right(goal));
    });
  });

  group('archiveGoal', () {
    test('updates status to archived and returns unit', () async {
      when(() => local.updateStatus('g1', 'archived')).thenAnswer((_) async {});

      final result = await repo.archiveGoal('g1');

      expect(result, const Right(unit));
      verify(() => local.updateStatus('g1', 'archived')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.updateStatus(any(), any())).thenThrow(Exception('err'));

      final result = await repo.archiveGoal('g1');

      expect(
        result,
        const Left(Failure.database(message: 'Failed to archive goal')),
      );
    });
  });
}
