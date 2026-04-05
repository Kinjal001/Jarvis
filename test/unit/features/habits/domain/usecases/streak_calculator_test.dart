import 'package:flutter_test/flutter_test.dart';

import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';
import 'package:jarvis/features/habits/domain/usecases/streak_calculator.dart';

/// Build a HabitCompletion with a specific date (time set to noon to avoid
/// any accidental date-boundary edge cases).
HabitCompletion _completion(DateTime date) => HabitCompletion(
  id: date.toIso8601String(),
  habitId: 'h1',
  userId: 'u1',
  completedAt: DateTime(date.year, date.month, date.day, 12),
);

/// Shorthand: days ago from today (0 = today, 1 = yesterday, …)
DateTime _daysAgo(int n) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(Duration(days: n));
}

void main() {
  group('StreakCalculator.currentStreak — daily', () {
    test('returns 0 for empty completions', () {
      expect(StreakCalculator.currentStreak([], HabitFrequency.daily), 0);
    });

    test('returns 0 when last completion was 2+ days ago', () {
      final completions = [_completion(_daysAgo(2))];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        0,
      );
    });

    test('returns 1 when only completed today', () {
      final completions = [_completion(_daysAgo(0))];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        1,
      );
    });

    test('returns 1 when only completed yesterday (today not done yet)', () {
      final completions = [_completion(_daysAgo(1))];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        1,
      );
    });

    test(
      'returns streak length when completed consecutive days ending today',
      () {
        final completions = [
          _completion(_daysAgo(0)),
          _completion(_daysAgo(1)),
          _completion(_daysAgo(2)),
        ];
        expect(
          StreakCalculator.currentStreak(completions, HabitFrequency.daily),
          3,
        );
      },
    );

    test('returns streak length when consecutive ending yesterday', () {
      final completions = [
        _completion(_daysAgo(1)),
        _completion(_daysAgo(2)),
        _completion(_daysAgo(3)),
      ];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        3,
      );
    });

    test('gap in history does not affect current streak', () {
      // Completed 0, 1, 2 days ago and also 10 days ago (older history).
      // Current streak should be 3, ignoring the distant completion.
      final completions = [
        _completion(_daysAgo(0)),
        _completion(_daysAgo(1)),
        _completion(_daysAgo(2)),
        _completion(_daysAgo(10)),
      ];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        3,
      );
    });

    test('multiple completions on same day count as one for streak', () {
      final completions = [
        _completion(_daysAgo(0)),
        _completion(_daysAgo(0)), // duplicate date
        _completion(_daysAgo(1)),
      ];
      expect(
        StreakCalculator.currentStreak(completions, HabitFrequency.daily),
        2,
      );
    });
  });

  group('StreakCalculator.longestStreak', () {
    test('returns 0 for empty completions', () {
      expect(StreakCalculator.longestStreak([], HabitFrequency.daily), 0);
    });

    test('returns 1 for a single completion', () {
      final completions = [_completion(_daysAgo(5))];
      expect(
        StreakCalculator.longestStreak(completions, HabitFrequency.daily),
        1,
      );
    });

    test('returns the length of the longest unbroken run', () {
      // Two runs: 3-day run and 2-day run, with a gap between them.
      final completions = [
        _completion(_daysAgo(10)),
        _completion(_daysAgo(9)),
        _completion(_daysAgo(8)),
        // gap on day 7
        _completion(_daysAgo(6)),
        _completion(_daysAgo(5)),
      ];
      expect(
        StreakCalculator.longestStreak(completions, HabitFrequency.daily),
        3,
      );
    });

    test('returns full length when all completions are consecutive', () {
      final completions = List.generate(7, (i) => _completion(_daysAgo(i)));
      expect(
        StreakCalculator.longestStreak(completions, HabitFrequency.daily),
        7,
      );
    });

    test('ignores duplicate dates', () {
      // Days 0,1,2 with day 1 logged twice — still a 3-day streak.
      final completions = [
        _completion(_daysAgo(0)),
        _completion(_daysAgo(1)),
        _completion(_daysAgo(1)),
        _completion(_daysAgo(2)),
      ];
      expect(
        StreakCalculator.longestStreak(completions, HabitFrequency.daily),
        3,
      );
    });
  });

  group('StreakCalculator.isCompletedToday', () {
    test('returns false for empty completions', () {
      expect(StreakCalculator.isCompletedToday([]), isFalse);
    });

    test('returns false when latest completion was yesterday', () {
      final completions = [_completion(_daysAgo(1))];
      expect(StreakCalculator.isCompletedToday(completions), isFalse);
    });

    test('returns true when completed today', () {
      final completions = [_completion(_daysAgo(0))];
      expect(StreakCalculator.isCompletedToday(completions), isTrue);
    });

    test('returns true when completed today among other entries', () {
      final completions = [
        _completion(_daysAgo(3)),
        _completion(_daysAgo(0)),
        _completion(_daysAgo(1)),
      ];
      expect(StreakCalculator.isCompletedToday(completions), isTrue);
    });
  });
}
