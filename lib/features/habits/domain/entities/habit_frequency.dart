/// How often a habit repeats.
enum HabitFrequency {
  /// Every day without exception.
  daily,

  /// On specific days of the week defined by [Habit.targetDaysOfWeek].
  /// Days are ISO 8601 integers: 1 = Monday … 7 = Sunday.
  weekly,
}
