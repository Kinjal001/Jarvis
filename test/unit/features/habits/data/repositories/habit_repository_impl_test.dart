import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/habits/data/datasources/habit_local_datasource.dart';
import 'package:jarvis/features/habits/data/datasources/habit_remote_datasource.dart';
import 'package:jarvis/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitLocalDatasource extends Mock implements HabitLocalDatasource {}

class MockHabitRemoteDatasource extends Mock implements HabitRemoteDatasource {}

Habit _makeHabit({String id = 'h1'}) => Habit(
  id: id,
  userId: 'u1',
  title: 'Meditate',
  frequency: HabitFrequency.daily,
  targetDaysOfWeek: const [],
  targetCount: 1,
  colorHex: '#7C3AED',
  isActive: true,
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);

HabitCompletion _makeCompletion({String id = 'c1'}) => HabitCompletion(
  id: id,
  habitId: 'h1',
  userId: 'u1',
  completedAt: DateTime(2025, 1, 1, 12),
);

HabitRow _makeHabitRow({String id = 'h1'}) => HabitRow(
  id: id,
  userId: 'u1',
  title: 'Meditate',
  description: null,
  frequency: 'daily',
  targetDaysOfWeek: '',
  targetCount: 1,
  colorHex: '#7C3AED',
  isActive: true,
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
  syncStatus: 'synced',
);

HabitCompletionRow _makeCompletionRow({String id = 'c1'}) => HabitCompletionRow(
  id: id,
  habitId: 'h1',
  userId: 'u1',
  completedAt: DateTime(2025, 1, 1, 12),
  note: null,
  syncStatus: 'synced',
);

void main() {
  late MockHabitLocalDatasource local;
  late MockHabitRemoteDatasource remote;
  late HabitRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_makeHabit());
    registerFallbackValue(_makeCompletion());
    registerFallbackValue(HabitFrequency.daily);
    registerFallbackValue(const HabitsTableCompanion());
    registerFallbackValue(const HabitCompletionsTableCompanion());
  });

  setUp(() {
    local = MockHabitLocalDatasource();
    remote = MockHabitRemoteDatasource();
    repo = HabitRepositoryImpl(local, remote);
  });

  group('getHabits', () {
    test('returns mapped list from local', () async {
      when(
        () => local.getAll(),
      ).thenAnswer((_) async => [_makeHabitRow(), _makeHabitRow(id: 'h2')]);

      final result = await repo.getHabits();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 2);
    });

    test('returns failure when local throws', () async {
      when(() => local.getAll()).thenThrow(Exception('db error'));

      final result = await repo.getHabits();

      expect(
        result,
        const Left(Failure.database(message: 'Failed to load habits')),
      );
    });
  });

  group('createHabit', () {
    test('writes to local and returns the habit', () async {
      final habit = _makeHabit();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsertHabit(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repo.createHabit(habit);

      expect(result, Right(habit));
      verify(() => local.upsert(any())).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.createHabit(_makeHabit()),
        const Left(Failure.database(message: 'Failed to create habit')),
      );
    });
  });

  group('updateHabit', () {
    test('writes to local and returns the habit', () async {
      final habit = _makeHabit();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsertHabit(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      final result = await repo.updateHabit(habit);

      expect(result, Right(habit));
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.updateHabit(_makeHabit()),
        const Left(Failure.database(message: 'Failed to update habit')),
      );
    });
  });

  group('archiveHabit', () {
    test('calls archive and returns unit', () async {
      when(() => local.archive('h1')).thenAnswer((_) async {});

      final result = await repo.archiveHabit('h1');

      expect(result, const Right(unit));
      verify(() => local.archive('h1')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.archive(any())).thenThrow(Exception('error'));

      expect(
        await repo.archiveHabit('h1'),
        const Left(Failure.database(message: 'Failed to archive habit')),
      );
    });
  });

  group('logCompletion', () {
    test('writes completion to local and returns it', () async {
      final completion = _makeCompletion();
      when(() => local.upsertCompletion(any())).thenAnswer((_) async {});
      when(() => remote.upsertCompletion(any())).thenAnswer((_) async {});
      when(() => local.markCompletionSynced(any())).thenAnswer((_) async {});

      final result = await repo.logCompletion(completion);

      expect(result, Right(completion));
      verify(() => local.upsertCompletion(any())).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.upsertCompletion(any())).thenThrow(Exception('error'));

      expect(
        await repo.logCompletion(_makeCompletion()),
        const Left(Failure.database(message: 'Failed to log completion')),
      );
    });
  });

  group('getCompletions', () {
    test('returns mapped completions from local', () async {
      when(
        () => local.getCompletionsByHabitId('h1'),
      ).thenAnswer((_) async => [_makeCompletionRow()]);

      final result = await repo.getCompletions('h1');

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 1);
    });

    test('returns failure when local throws', () async {
      when(
        () => local.getCompletionsByHabitId(any()),
      ).thenThrow(Exception('error'));

      expect(
        await repo.getCompletions('h1'),
        const Left(Failure.database(message: 'Failed to load completions')),
      );
    });
  });

  group('deleteCompletion', () {
    test('deletes locally and calls remote', () async {
      when(() => local.deleteCompletion('c1')).thenAnswer((_) async {});
      when(() => remote.deleteCompletion('c1')).thenAnswer((_) async {});

      final result = await repo.deleteCompletion('c1');

      expect(result, const Right(unit));
      verify(() => local.deleteCompletion('c1')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.deleteCompletion(any())).thenThrow(Exception('error'));

      expect(
        await repo.deleteCompletion('c1'),
        const Left(Failure.database(message: 'Failed to delete completion')),
      );
    });
  });
}
