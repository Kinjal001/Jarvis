import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_completion.freezed.dart';

/// A single logged instance of a habit being performed.
///
/// Multiple completions on the same day are valid for countable habits
/// (e.g. logging each glass of water separately). The streak calculator
/// treats a day as "done" when ≥ 1 completion exists for that date.
@freezed
abstract class HabitCompletion with _$HabitCompletion {
  const factory HabitCompletion({
    required String id,
    required String habitId,
    required String userId,
    required DateTime completedAt,
    String? note,
  }) = _HabitCompletion;
}
