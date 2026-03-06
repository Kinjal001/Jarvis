import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:jarvis/features/goals/domain/usecases/archive_goal.dart';
import 'package:jarvis/features/goals/domain/usecases/create_goal.dart';
import 'package:jarvis/features/goals/domain/usecases/get_goals.dart';
import 'package:jarvis/features/goals/domain/usecases/update_goal.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalRepository extends Mock implements IGoalRepository {}

// A reusable test fixture for a valid Goal.
Goal _makeGoal({String id = '1'}) => Goal(
  id: id,
  userId: 'user-1',
  title: 'Learn ML',
  intention: 'Career change',
  priority: 1,
  status: GoalStatus.active,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  late MockGoalRepository repo;

  setUpAll(() => registerFallbackValue(_makeGoal()));
  setUp(() => repo = MockGoalRepository());

  group('CreateGoal', () {
    test('delegates to repository and returns the created goal', () async {
      final goal = _makeGoal();
      when(() => repo.createGoal(goal)).thenAnswer((_) async => Right(goal));

      final result = await CreateGoal(repo).call(goal);

      expect(result, Right(goal));
      verify(() => repo.createGoal(goal)).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'write error');
      when(
        () => repo.createGoal(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await CreateGoal(repo).call(_makeGoal());

      expect(result, const Left(failure));
    });
  });

  group('GetGoals', () {
    test('returns list of goals from repository', () async {
      final goals = [_makeGoal(id: '1'), _makeGoal(id: '2')];
      when(() => repo.getGoals()).thenAnswer((_) async => Right(goals));

      final result = await GetGoals(repo).call();

      expect(result, Right(goals));
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.network(message: 'offline');
      when(() => repo.getGoals()).thenAnswer((_) async => const Left(failure));

      final result = await GetGoals(repo).call();

      expect(result, const Left(failure));
    });
  });

  group('UpdateGoal', () {
    test('delegates updated goal to repository', () async {
      final updated = _makeGoal().copyWith(title: 'Learn ML Advanced');
      when(
        () => repo.updateGoal(updated),
      ).thenAnswer((_) async => Right(updated));

      final result = await UpdateGoal(repo).call(updated);

      expect(result, Right(updated));
      verify(() => repo.updateGoal(updated)).called(1);
    });
  });

  group('ArchiveGoal', () {
    test('calls archiveGoal with the correct id', () async {
      when(
        () => repo.archiveGoal('1'),
      ).thenAnswer((_) async => const Right(unit));

      final result = await ArchiveGoal(repo).call('1');

      expect(result, const Right(unit));
      verify(() => repo.archiveGoal('1')).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'archive error');
      when(
        () => repo.archiveGoal(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await ArchiveGoal(repo).call('1');

      expect(result, const Left(failure));
    });
  });
}
