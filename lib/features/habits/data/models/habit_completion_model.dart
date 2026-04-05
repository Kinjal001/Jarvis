import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/habits/domain/entities/habit_completion.dart';

class HabitCompletionModel {
  const HabitCompletionModel._();

  static HabitCompletion fromRow(HabitCompletionRow row) => HabitCompletion(
    id: row.id,
    habitId: row.habitId,
    userId: row.userId,
    completedAt: row.completedAt,
    note: row.note,
  );

  static HabitCompletionsTableCompanion toCompanion(
    HabitCompletion completion, {
    String syncStatus = 'pendingUpload',
  }) => HabitCompletionsTableCompanion(
    id: Value(completion.id),
    habitId: Value(completion.habitId),
    userId: Value(completion.userId),
    completedAt: Value(completion.completedAt),
    note: Value(completion.note),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(HabitCompletion completion) => {
    'id': completion.id,
    'habit_id': completion.habitId,
    'user_id': completion.userId,
    'completed_at': completion.completedAt.toIso8601String(),
    'note': completion.note,
  };

  static HabitCompletion fromRemoteMap(Map<String, dynamic> map) =>
      HabitCompletion(
        id: map['id'] as String,
        habitId: map['habit_id'] as String,
        userId: map['user_id'] as String,
        completedAt: DateTime.parse(map['completed_at'] as String),
        note: map['note'] as String?,
      );
}
