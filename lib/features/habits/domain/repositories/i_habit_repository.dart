import 'package:fpdart/fpdart.dart';

import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';

/// Contract for all habit persistence operations.
///
/// Implementations (in the data layer) decide whether to read from
/// the local Drift database, Supabase, or both.
abstract interface class IHabitRepository {
  /// Returns all active and archived habits for the signed-in user.
  Future<Either<Failure, List<Habit>>> getHabits();

  /// Persists a new habit and returns it.
  Future<Either<Failure, Habit>> createHabit(Habit habit);

  /// Overwrites an existing habit record and returns the updated value.
  Future<Either<Failure, Habit>> updateHabit(Habit habit);

  /// Marks a habit as inactive (soft-delete). Never hard-deletes —
  /// completion history must remain intact for streak history.
  Future<Either<Failure, Unit>> archiveHabit(String id);

  /// Records a single completion of a habit and returns it.
  Future<Either<Failure, HabitCompletion>> logCompletion(
    HabitCompletion completion,
  );

  /// Returns all completions for the given [habitId], newest first.
  Future<Either<Failure, List<HabitCompletion>>> getCompletions(String habitId);

  /// Removes a specific completion record (undo a mistaken log).
  Future<Either<Failure, Unit>> deleteCompletion(String id);
}
