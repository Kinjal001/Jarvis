import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';

class HabitModel {
  const HabitModel._();

  static List<int> _decodeDays(String encoded) =>
      encoded.isEmpty ? [] : encoded.split(',').map(int.parse).toList();

  static String _encodeDays(List<int> days) => days.join(',');

  static Habit fromRow(HabitRow row) => Habit(
    id: row.id,
    userId: row.userId,
    title: row.title,
    description: row.description,
    frequency: HabitFrequency.values.byName(row.frequency),
    targetDaysOfWeek: _decodeDays(row.targetDaysOfWeek),
    targetCount: row.targetCount,
    colorHex: row.colorHex,
    isActive: row.isActive,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static HabitsTableCompanion toCompanion(
    Habit habit, {
    String syncStatus = 'pendingUpload',
  }) => HabitsTableCompanion(
    id: Value(habit.id),
    userId: Value(habit.userId),
    title: Value(habit.title),
    description: Value(habit.description),
    frequency: Value(habit.frequency.name),
    targetDaysOfWeek: Value(_encodeDays(habit.targetDaysOfWeek)),
    targetCount: Value(habit.targetCount),
    colorHex: Value(habit.colorHex),
    isActive: Value(habit.isActive),
    createdAt: Value(habit.createdAt),
    updatedAt: Value(habit.updatedAt),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(Habit habit) => {
    'id': habit.id,
    'user_id': habit.userId,
    'title': habit.title,
    'description': habit.description,
    'frequency': habit.frequency.name,
    'target_days_of_week': habit.targetDaysOfWeek,
    'target_count': habit.targetCount,
    'color_hex': habit.colorHex,
    'is_active': habit.isActive,
    'created_at': habit.createdAt.toIso8601String(),
    'updated_at': habit.updatedAt.toIso8601String(),
  };

  static Habit fromRemoteMap(Map<String, dynamic> map) => Habit(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    frequency: HabitFrequency.values.byName(map['frequency'] as String),
    targetDaysOfWeek: (map['target_days_of_week'] as List<dynamic>)
        .map((e) => e as int)
        .toList(),
    targetCount: map['target_count'] as int,
    colorHex: map['color_hex'] as String,
    isActive: map['is_active'] as bool,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
