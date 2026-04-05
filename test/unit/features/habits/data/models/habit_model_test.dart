import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/habits/data/models/habit_model.dart';
import 'package:jarvis/features/habits/domain/entities/habit.dart';
import 'package:jarvis/features/habits/domain/entities/habit_frequency.dart';

AppDatabase _makeDb() => AppDatabase(NativeDatabase.memory());

Habit _makeHabit({
  HabitFrequency frequency = HabitFrequency.daily,
  List<int> targetDays = const [],
}) => Habit(
  id: 'h1',
  userId: 'u1',
  title: 'Meditate',
  frequency: frequency,
  targetDaysOfWeek: targetDays,
  targetCount: 1,
  colorHex: '#7C3AED',
  isActive: true,
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);

HabitRow _makeRow({String frequency = 'daily', String targetDaysOfWeek = ''}) =>
    HabitRow(
      id: 'h1',
      userId: 'u1',
      title: 'Meditate',
      description: null,
      frequency: frequency,
      targetDaysOfWeek: targetDaysOfWeek,
      targetCount: 1,
      colorHex: '#7C3AED',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
      syncStatus: 'synced',
    );

void main() {
  group('HabitModel.fromRow', () {
    test('maps all fields correctly', () {
      final habit = HabitModel.fromRow(_makeRow());

      expect(habit.id, 'h1');
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.targetDaysOfWeek, isEmpty);
    });

    test('decodes comma-separated targetDaysOfWeek', () {
      final habit = HabitModel.fromRow(
        _makeRow(frequency: 'weekly', targetDaysOfWeek: '1,3,5'),
      );

      expect(habit.frequency, HabitFrequency.weekly);
      expect(habit.targetDaysOfWeek, [1, 3, 5]);
    });

    test('decodes single-day targetDaysOfWeek', () {
      final habit = HabitModel.fromRow(
        _makeRow(frequency: 'weekly', targetDaysOfWeek: '2'),
      );

      expect(habit.targetDaysOfWeek, [2]);
    });
  });

  group('HabitModel.toCompanion', () {
    test('encodes daily habit with empty targetDaysOfWeek', () {
      final companion = HabitModel.toCompanion(_makeHabit());

      expect(companion.frequency.value, 'daily');
      expect(companion.targetDaysOfWeek.value, '');
      expect(companion.syncStatus.value, 'pendingUpload');
    });

    test('encodes weekly habit with days as CSV', () {
      final companion = HabitModel.toCompanion(
        _makeHabit(frequency: HabitFrequency.weekly, targetDays: [1, 3, 5]),
      );

      expect(companion.frequency.value, 'weekly');
      expect(companion.targetDaysOfWeek.value, '1,3,5');
    });

    test('respects custom syncStatus', () {
      final companion = HabitModel.toCompanion(
        _makeHabit(),
        syncStatus: 'synced',
      );

      expect(companion.syncStatus.value, 'synced');
    });
  });

  group('HabitModel.toRemoteMap', () {
    test('produces correct keys and values', () {
      final map = HabitModel.toRemoteMap(
        _makeHabit(frequency: HabitFrequency.weekly, targetDays: [2, 4]),
      );

      expect(map['id'], 'h1');
      expect(map['user_id'], 'u1');
      expect(map['frequency'], 'weekly');
      expect(map['target_days_of_week'], [2, 4]);
      expect(map['is_active'], true);
    });
  });

  group('HabitModel.fromRemoteMap', () {
    test('parses all fields', () {
      final habit = HabitModel.fromRemoteMap({
        'id': 'h2',
        'user_id': 'u1',
        'title': 'Read',
        'description': null,
        'frequency': 'daily',
        'target_days_of_week': <dynamic>[],
        'target_count': 1,
        'color_hex': '#7C3AED',
        'is_active': true,
        'created_at': '2025-01-01T00:00:00.000',
        'updated_at': '2025-01-01T00:00:00.000',
      });

      expect(habit.id, 'h2');
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.targetDaysOfWeek, isEmpty);
    });

    test('round-trips through toRemoteMap', () {
      final original = _makeHabit(
        frequency: HabitFrequency.weekly,
        targetDays: [1, 5],
      );
      final roundTripped = HabitModel.fromRemoteMap(
        HabitModel.toRemoteMap(original),
      );

      expect(roundTripped.id, original.id);
      expect(roundTripped.frequency, original.frequency);
      expect(roundTripped.targetDaysOfWeek, original.targetDaysOfWeek);
    });
  });

  group('HabitModel round-trip via DB', () {
    late AppDatabase db;

    setUp(() => db = _makeDb());
    tearDown(() => db.close());

    test('fromRow(toCompanion(habit)) preserves all fields', () async {
      final habit = _makeHabit(
        frequency: HabitFrequency.weekly,
        targetDays: [3, 6],
      );
      await db
          .into(db.habitsTable)
          .insertOnConflictUpdate(HabitModel.toCompanion(habit));

      final rows = await db.select(db.habitsTable).get();
      final recovered = HabitModel.fromRow(rows.first);

      expect(recovered.frequency, HabitFrequency.weekly);
      expect(recovered.targetDaysOfWeek, [3, 6]);
      expect(recovered.title, 'Meditate');
    });
  });
}
