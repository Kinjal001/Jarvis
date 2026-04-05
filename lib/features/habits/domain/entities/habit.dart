import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';

part 'habit.freezed.dart';

/// A repeating behaviour the user wants to build or track.
///
/// A habit is distinct from a [Task] in that it recurs on a schedule and
/// its value comes from the streak of consecutive completions, not from
/// a single act of completion.
///
/// [targetDaysOfWeek] is only meaningful when [frequency] is
/// [HabitFrequency.weekly]. Values are ISO 8601 weekday integers
/// (1 = Monday … 7 = Sunday). Ignored for [HabitFrequency.daily].
///
/// [targetCount] is how many times the habit should be logged per period
/// (usually 1). Enables countable habits like "drink 8 glasses of water".
///
/// [colorHex] is a '#RRGGBB' string drawn from the app's accent palette
/// (violet for habits by default, but user-selectable).
@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String userId,
    required String title,
    String? description,
    required HabitFrequency frequency,
    required List<int> targetDaysOfWeek,
    required int targetCount,
    required String colorHex,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Habit;
}
