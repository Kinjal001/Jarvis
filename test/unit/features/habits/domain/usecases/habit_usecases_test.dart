import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';
import 'package:jarvis/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:jarvis/features/habits/domain/usecases/habit_usecases.dart';

class MockHabitRepository extends Mock implements IHabitRepository {}

Habit _makeHabit(String id) {
  final now = DateTime.now();
  return Habit(
    id: id,
    userId: 'u1',
    title: 'Exercise',
    frequency: HabitFrequency.daily,
    targetDaysOfWeek: const [],
    targetCount: 1,
    colorHex: '#7C3AED',
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

HabitCompletion _makeCompletion(String id, String habitId) {
  return HabitCompletion(
    id: id,
    habitId: habitId,
    userId: 'u1',
    completedAt: DateTime.now(),
  );
}

void main() {
  late MockHabitRepository repository;

  setUpAll(() {
    registerFallbackValue(_makeHabit('fallback'));
    registerFallbackValue(_makeCompletion('fallback', 'h1'));
    registerFallbackValue(HabitFrequency.daily);
  });

  setUp(() {
    repository = MockHabitRepository();
  });

  group('GetHabits', () {
    test('returns list of habits from repository', () async {
      final habits = [_makeHabit('h1'), _makeHabit('h2')];
      when(() => repository.getHabits()).thenAnswer((_) async => Right(habits));

      final result = await GetHabits(repository).call();

      expect(result, Right(habits));
      verify(() => repository.getHabits()).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'db error');
      when(
        () => repository.getHabits(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await GetHabits(repository).call();

      expect(result, const Left(failure));
    });
  });

  group('CreateHabit', () {
    test('delegates to repository and returns created habit', () async {
      final habit = _makeHabit('h1');
      when(
        () => repository.createHabit(any()),
      ).thenAnswer((_) async => Right(habit));

      final result = await CreateHabit(repository).call(habit);

      expect(result, Right(habit));
      verify(() => repository.createHabit(habit)).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'write failed');
      when(
        () => repository.createHabit(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await CreateHabit(repository).call(_makeHabit('h1'));

      expect(result, const Left(failure));
    });
  });

  group('UpdateHabit', () {
    test('delegates updated habit to repository', () async {
      final habit = _makeHabit('h1');
      when(
        () => repository.updateHabit(any()),
      ).thenAnswer((_) async => Right(habit));

      final result = await UpdateHabit(repository).call(habit);

      expect(result, Right(habit));
      verify(() => repository.updateHabit(habit)).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'update failed');
      when(
        () => repository.updateHabit(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await UpdateHabit(repository).call(_makeHabit('h1'));

      expect(result, const Left(failure));
    });
  });

  group('ArchiveHabit', () {
    test('calls archiveHabit with the correct id', () async {
      when(
        () => repository.archiveHabit(any()),
      ).thenAnswer((_) async => const Right(unit));

      final result = await ArchiveHabit(repository).call('h1');

      expect(result, const Right(unit));
      verify(() => repository.archiveHabit('h1')).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'archive failed');
      when(
        () => repository.archiveHabit(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await ArchiveHabit(repository).call('h1');

      expect(result, const Left(failure));
    });
  });

  group('LogHabitCompletion', () {
    test('delegates to repository and returns the completion', () async {
      final completion = _makeCompletion('c1', 'h1');
      when(
        () => repository.logCompletion(any()),
      ).thenAnswer((_) async => Right(completion));

      final result = await LogHabitCompletion(repository).call(completion);

      expect(result, Right(completion));
      verify(() => repository.logCompletion(completion)).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'log failed');
      when(
        () => repository.logCompletion(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await LogHabitCompletion(
        repository,
      ).call(_makeCompletion('c1', 'h1'));

      expect(result, const Left(failure));
    });
  });

  group('GetHabitCompletions', () {
    test('returns completions for given habitId', () async {
      final completions = [
        _makeCompletion('c1', 'h1'),
        _makeCompletion('c2', 'h1'),
      ];
      when(
        () => repository.getCompletions(any()),
      ).thenAnswer((_) async => Right(completions));

      final result = await GetHabitCompletions(repository).call('h1');

      expect(result, Right(completions));
      verify(() => repository.getCompletions('h1')).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'fetch failed');
      when(
        () => repository.getCompletions(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await GetHabitCompletions(repository).call('h1');

      expect(result, const Left(failure));
    });
  });

  group('DeleteHabitCompletion', () {
    test('calls deleteCompletion with correct id', () async {
      when(
        () => repository.deleteCompletion(any()),
      ).thenAnswer((_) async => const Right(unit));

      final result = await DeleteHabitCompletion(repository).call('c1');

      expect(result, const Right(unit));
      verify(() => repository.deleteCompletion('c1')).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'delete failed');
      when(
        () => repository.deleteCompletion(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await DeleteHabitCompletion(repository).call('c1');

      expect(result, const Left(failure));
    });
  });
}
