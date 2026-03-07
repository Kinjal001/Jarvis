import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/goals/data/models/goal_model.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';

void main() {
  const id = 'g1';
  const userId = 'u1';
  const title = 'Learn ML';
  const intention = 'Career change';
  final createdAt = DateTime(2024);
  final updatedAt = DateTime(2024);

  final row = GoalRow(
    id: id,
    userId: userId,
    title: title,
    intention: intention,
    deadline: null,
    priority: 1,
    status: 'active',
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: 'synced',
  );

  final goal = Goal(
    id: id,
    userId: userId,
    title: title,
    intention: intention,
    priority: 1,
    status: GoalStatus.active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('GoalModel.fromRow', () {
    test('maps all fields from Drift row to domain entity', () {
      expect(GoalModel.fromRow(row), goal);
    });

    test('preserves nullable deadline when set', () {
      final deadline = DateTime(2025);
      final rowWithDeadline = GoalRow(
        id: id,
        userId: userId,
        title: title,
        intention: intention,
        deadline: deadline,
        priority: 1,
        status: 'active',
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: 'synced',
      );
      expect(GoalModel.fromRow(rowWithDeadline).deadline, deadline);
    });

    test('maps each GoalStatus value correctly', () {
      for (final status in GoalStatus.values) {
        final r = GoalRow(
          id: id,
          userId: userId,
          title: title,
          intention: intention,
          priority: 1,
          status: status.name,
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );
        expect(GoalModel.fromRow(r).status, status);
      }
    });
  });

  group('GoalModel.toCompanion', () {
    test('maps entity fields into companion', () {
      final companion = GoalModel.toCompanion(goal);
      expect(companion.id.value, id);
      expect(companion.userId.value, userId);
      expect(companion.title.value, title);
      expect(companion.status.value, 'active');
      expect(companion.syncStatus.value, 'pendingUpload');
    });

    test('accepts a custom syncStatus', () {
      final companion = GoalModel.toCompanion(goal, syncStatus: 'synced');
      expect(companion.syncStatus.value, 'synced');
    });
  });

  group('GoalModel.toRemoteMap', () {
    test('produces correct Supabase column names', () {
      final map = GoalModel.toRemoteMap(goal);
      expect(map['id'], id);
      expect(map['user_id'], userId);
      expect(map['title'], title);
      expect(map['intention'], intention);
      expect(map['status'], 'active');
      expect(map['deadline'], isNull);
    });

    test('formats deadline as ISO 8601 string when set', () {
      final deadline = DateTime(2025, 6, 1);
      final goalWithDeadline = goal.copyWith(deadline: deadline);
      final map = GoalModel.toRemoteMap(goalWithDeadline);
      expect(map['deadline'], deadline.toIso8601String());
    });
  });

  group('GoalModel.fromRemoteMap', () {
    test('round-trips correctly through toRemoteMap', () {
      final map = GoalModel.toRemoteMap(goal);
      expect(GoalModel.fromRemoteMap(map), goal);
    });

    test('handles null deadline', () {
      final map = GoalModel.toRemoteMap(goal);
      expect(GoalModel.fromRemoteMap(map).deadline, isNull);
    });

    test('parses deadline ISO string', () {
      final deadline = DateTime(2025, 6, 1);
      final goalWithDeadline = goal.copyWith(deadline: deadline);
      final map = GoalModel.toRemoteMap(goalWithDeadline);
      expect(GoalModel.fromRemoteMap(map).deadline, deadline);
    });
  });
}
