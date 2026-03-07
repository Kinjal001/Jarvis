import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/tasks/data/models/task_model.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';

void main() {
  final createdAt = DateTime(2024);
  final updatedAt = DateTime(2024);

  final row = TaskRow(
    id: 't1',
    userId: 'u1',
    title: 'Buy groceries',
    description: null,
    dueDate: null,
    priority: 2,
    status: 'pending',
    isRecurring: false,
    recurrenceRule: null,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: 'synced',
  );

  final task = Task(
    id: 't1',
    userId: 'u1',
    title: 'Buy groceries',
    priority: 2,
    status: TaskStatus.pending,
    isRecurring: false,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('TaskModel.fromRow', () {
    test('maps all fields from Drift row to domain entity', () {
      expect(TaskModel.fromRow(row), task);
    });

    test('maps each TaskStatus value correctly', () {
      for (final status in TaskStatus.values) {
        final r = TaskRow(
          id: 't1',
          userId: 'u1',
          title: 'T',
          priority: 1,
          status: status.name,
          isRecurring: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );
        expect(TaskModel.fromRow(r).status, status);
      }
    });

    test('preserves nullable dueDate when set', () {
      final due = DateTime(2024, 6, 1);
      final r = TaskRow(
        id: 't1',
        userId: 'u1',
        title: 'T',
        priority: 1,
        status: 'pending',
        isRecurring: false,
        dueDate: due,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: 'synced',
      );
      expect(TaskModel.fromRow(r).dueDate, due);
    });
  });

  group('TaskModel.toCompanion', () {
    test('maps entity fields into companion', () {
      final companion = TaskModel.toCompanion(task);
      expect(companion.id.value, 't1');
      expect(companion.userId.value, 'u1');
      expect(companion.status.value, 'pending');
      expect(companion.syncStatus.value, 'pendingUpload');
    });

    test('accepts a custom syncStatus', () {
      final c = TaskModel.toCompanion(task, syncStatus: 'synced');
      expect(c.syncStatus.value, 'synced');
    });
  });

  group('TaskModel.toRemoteMap', () {
    test('produces correct Supabase column names', () {
      final map = TaskModel.toRemoteMap(task);
      expect(map['id'], 't1');
      expect(map['user_id'], 'u1');
      expect(map['status'], 'pending');
      expect(map['is_recurring'], false);
      expect(map['due_date'], isNull);
    });

    test('formats dueDate as ISO string when set', () {
      final due = DateTime(2024, 6, 1);
      final t = task.copyWith(dueDate: due);
      expect(TaskModel.toRemoteMap(t)['due_date'], due.toIso8601String());
    });
  });

  group('TaskModel.fromRemoteMap', () {
    test('round-trips correctly through toRemoteMap', () {
      expect(TaskModel.fromRemoteMap(TaskModel.toRemoteMap(task)), task);
    });

    test('handles null optional fields', () {
      final restored = TaskModel.fromRemoteMap(TaskModel.toRemoteMap(task));
      expect(restored.dueDate, isNull);
      expect(restored.description, isNull);
      expect(restored.recurrenceRule, isNull);
    });
  });
}
