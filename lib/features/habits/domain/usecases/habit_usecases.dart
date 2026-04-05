import 'package:fpdart/fpdart.dart';

import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/repositories/i_habit_repository.dart';

// ── Habit CRUD ────────────────────────────────────────────────────────────────

class GetHabits {
  final IHabitRepository _repository;
  const GetHabits(this._repository);

  Future<Either<Failure, List<Habit>>> call() => _repository.getHabits();
}

class CreateHabit {
  final IHabitRepository _repository;
  const CreateHabit(this._repository);

  Future<Either<Failure, Habit>> call(Habit habit) =>
      _repository.createHabit(habit);
}

class UpdateHabit {
  final IHabitRepository _repository;
  const UpdateHabit(this._repository);

  Future<Either<Failure, Habit>> call(Habit habit) =>
      _repository.updateHabit(habit);
}

class ArchiveHabit {
  final IHabitRepository _repository;
  const ArchiveHabit(this._repository);

  Future<Either<Failure, Unit>> call(String id) => _repository.archiveHabit(id);
}

// ── Completion logging ────────────────────────────────────────────────────────

class LogHabitCompletion {
  final IHabitRepository _repository;
  const LogHabitCompletion(this._repository);

  Future<Either<Failure, HabitCompletion>> call(HabitCompletion completion) =>
      _repository.logCompletion(completion);
}

class GetHabitCompletions {
  final IHabitRepository _repository;
  const GetHabitCompletions(this._repository);

  Future<Either<Failure, List<HabitCompletion>>> call(String habitId) =>
      _repository.getCompletions(habitId);
}

class DeleteHabitCompletion {
  final IHabitRepository _repository;
  const DeleteHabitCompletion(this._repository);

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteCompletion(id);
}
