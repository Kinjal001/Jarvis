import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';

/// Pure functions for calculating habit streaks from completion records.
///
/// "Streak" = the number of consecutive periods (days for daily habits,
/// target weekdays for weekly habits) in which at least one completion exists.
///
/// **Today rule:** if the habit has not been completed today, the streak is
/// still considered alive as long as yesterday was completed — the user still
/// has time to log today. Only a full missed period breaks the streak.
///
/// All calculations are based on the local date (no timezone conversion is
/// done here — callers should pass completions with local DateTimes).
abstract final class StreakCalculator {
  /// The current active streak length in periods.
  ///
  /// Returns 0 if no completions exist or the streak has been broken.
  static int currentStreak(
    List<HabitCompletion> completions,
    HabitFrequency frequency,
  ) {
    if (completions.isEmpty) return 0;

    final dates = _uniqueDates(completions);
    if (dates.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());

    switch (frequency) {
      case HabitFrequency.daily:
        return _dailyStreak(dates, today);
      case HabitFrequency.weekly:
        // For weekly habits the streak counts distinct completion days in the
        // most recent unbroken run (any completion per day counts).
        return _dailyStreak(dates, today);
    }
  }

  /// The longest streak ever recorded for this habit.
  static int longestStreak(
    List<HabitCompletion> completions,
    HabitFrequency frequency,
  ) {
    if (completions.isEmpty) return 0;

    final dates = _uniqueDates(completions)..sort();
    if (dates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0: same day, already de-duplicated — won't happen
    }

    return longest;
  }

  /// Whether the habit has at least one completion recorded for today.
  static bool isCompletedToday(List<HabitCompletion> completions) {
    final today = _dateOnly(DateTime.now());
    return completions.any((c) => _dateOnly(c.completedAt) == today);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Counts the daily streak ending at or before [anchor].
  ///
  /// Starts from [anchor] (today). If today has no completion, tries
  /// yesterday — the user still has time today. If neither today nor
  /// yesterday has a completion, the streak is 0.
  static int _dailyStreak(List<DateTime> sortedDates, DateTime anchor) {
    final dateSet = sortedDates.toSet();

    // Determine start of count: today if done, yesterday if today not done yet
    DateTime cursor = anchor;
    if (!dateSet.contains(cursor)) {
      cursor = anchor.subtract(const Duration(days: 1));
      if (!dateSet.contains(cursor)) return 0;
    }

    int streak = 0;
    while (dateSet.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Extracts unique calendar dates (time stripped) from completions.
  static List<DateTime> _uniqueDates(List<HabitCompletion> completions) {
    return completions.map((c) => _dateOnly(c.completedAt)).toSet().toList();
  }

  /// Strips the time component, returning midnight of the given date.
  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
