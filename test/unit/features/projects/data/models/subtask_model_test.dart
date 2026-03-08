import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/data/models/subtask_model.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';

void main() {
  final createdAt = DateTime(2024);
  final updatedAt = DateTime(2024);

  final row = SubtaskRow(
    id: 's1',
    projectId: 'p1',
    title: 'Watch lesson 1',
    description: null,
    deadline: null,
    isRecurring: false,
    recurrenceRule: null,
    status: 'pending',
    sortOrder: 0,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: 'synced',
  );

  final subtask = Subtask(
    id: 's1',
    projectId: 'p1',
    title: 'Watch lesson 1',
    isRecurring: false,
    status: SubtaskStatus.pending,
    sortOrder: 0,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('SubtaskModel.fromRow', () {
    test('maps all fields from Drift row to domain entity', () {
      expect(SubtaskModel.fromRow(row), subtask);
    });

    test('maps each SubtaskStatus value correctly', () {
      for (final status in SubtaskStatus.values) {
        final r = SubtaskRow(
          id: 's1',
          projectId: 'p1',
          title: 'T',
          isRecurring: false,
          status: status.name,
          sortOrder: 0,
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );
        expect(SubtaskModel.fromRow(r).status, status);
      }
    });

    test('maps recurrence fields when set', () {
      final r = SubtaskRow(
        id: 's1',
        projectId: 'p1',
        title: 'T',
        isRecurring: true,
        recurrenceRule: 'FREQ=DAILY',
        status: 'pending',
        sortOrder: 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: 'synced',
      );
      final s = SubtaskModel.fromRow(r);
      expect(s.isRecurring, true);
      expect(s.recurrenceRule, 'FREQ=DAILY');
    });
  });

  group('SubtaskModel.toCompanion', () {
    test('maps entity fields into companion', () {
      final companion = SubtaskModel.toCompanion(subtask);
      expect(companion.id.value, 's1');
      expect(companion.projectId.value, 'p1');
      expect(companion.status.value, 'pending');
      expect(companion.syncStatus.value, 'pendingUpload');
    });

    test('accepts a custom syncStatus', () {
      final c = SubtaskModel.toCompanion(subtask, syncStatus: 'synced');
      expect(c.syncStatus.value, 'synced');
    });
  });

  group('SubtaskModel.toRemoteMap', () {
    test('produces correct Supabase column names', () {
      final map = SubtaskModel.toRemoteMap(subtask);
      expect(map['id'], 's1');
      expect(map['project_id'], 'p1');
      expect(map['status'], 'pending');
      expect(map['is_recurring'], false);
      expect(map['sort_order'], 0);
    });
  });

  group('SubtaskModel.fromRemoteMap', () {
    test('round-trips correctly through toRemoteMap', () {
      expect(
        SubtaskModel.fromRemoteMap(SubtaskModel.toRemoteMap(subtask)),
        subtask,
      );
    });

    test('handles null optional fields', () {
      final restored = SubtaskModel.fromRemoteMap(
        SubtaskModel.toRemoteMap(subtask),
      );
      expect(restored.description, isNull);
      expect(restored.recurrenceRule, isNull);
      expect(restored.deadline, isNull);
    });
  });
}
