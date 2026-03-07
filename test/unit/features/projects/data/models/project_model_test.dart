import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/data/models/project_model.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';

void main() {
  final createdAt = DateTime(2024);
  final updatedAt = DateTime(2024);

  final row = ProjectRow(
    id: 'p1',
    userId: 'u1',
    goalId: 'g1',
    title: 'Complete Fast.ai',
    description: 'Online ML course',
    deadline: null,
    priority: 1,
    status: 'active',
    resourceLink: null,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: 'synced',
  );

  final project = Project(
    id: 'p1',
    userId: 'u1',
    goalId: 'g1',
    title: 'Complete Fast.ai',
    description: 'Online ML course',
    priority: 1,
    status: ProjectStatus.active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('ProjectModel.fromRow', () {
    test('maps all fields from Drift row to domain entity', () {
      expect(ProjectModel.fromRow(row), project);
    });

    test('preserves nullable goalId', () {
      final rowNoGoal = ProjectRow(
        id: 'p1',
        userId: 'u1',
        goalId: null,
        title: 'Standalone',
        priority: 1,
        status: 'active',
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: 'synced',
      );
      expect(ProjectModel.fromRow(rowNoGoal).goalId, isNull);
    });

    test('maps each ProjectStatus value correctly', () {
      for (final status in ProjectStatus.values) {
        final r = ProjectRow(
          id: 'p1',
          userId: 'u1',
          title: 'T',
          priority: 1,
          status: status.name,
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );
        expect(ProjectModel.fromRow(r).status, status);
      }
    });
  });

  group('ProjectModel.toCompanion', () {
    test('maps entity fields into companion', () {
      final companion = ProjectModel.toCompanion(project);
      expect(companion.id.value, 'p1');
      expect(companion.goalId.value, 'g1');
      expect(companion.status.value, 'active');
      expect(companion.syncStatus.value, 'pendingUpload');
    });

    test('accepts a custom syncStatus', () {
      final c = ProjectModel.toCompanion(project, syncStatus: 'synced');
      expect(c.syncStatus.value, 'synced');
    });
  });

  group('ProjectModel.toRemoteMap', () {
    test('produces correct Supabase column names', () {
      final map = ProjectModel.toRemoteMap(project);
      expect(map['id'], 'p1');
      expect(map['user_id'], 'u1');
      expect(map['goal_id'], 'g1');
      expect(map['status'], 'active');
    });

    test('formats deadline as ISO string when set', () {
      final deadline = DateTime(2025);
      final p = project.copyWith(deadline: deadline);
      expect(
        ProjectModel.toRemoteMap(p)['deadline'],
        deadline.toIso8601String(),
      );
    });
  });

  group('ProjectModel.fromRemoteMap', () {
    test('round-trips correctly through toRemoteMap', () {
      expect(
        ProjectModel.fromRemoteMap(ProjectModel.toRemoteMap(project)),
        project,
      );
    });

    test('handles null optional fields', () {
      final p = project.copyWith(
        goalId: null,
        description: null,
        resourceLink: null,
      );
      final restored = ProjectModel.fromRemoteMap(ProjectModel.toRemoteMap(p));
      expect(restored.goalId, isNull);
      expect(restored.description, isNull);
    });
  });
}
