import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';

class ProjectModel {
  const ProjectModel._();

  static Project fromRow(ProjectRow row) => Project(
    id: row.id,
    userId: row.userId,
    goalId: row.goalId,
    title: row.title,
    description: row.description,
    deadline: row.deadline,
    priority: row.priority,
    status: ProjectStatus.values.byName(row.status),
    resourceLink: row.resourceLink,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static ProjectsTableCompanion toCompanion(
    Project project, {
    String syncStatus = 'pendingUpload',
  }) => ProjectsTableCompanion(
    id: Value(project.id),
    userId: Value(project.userId),
    goalId: Value(project.goalId),
    title: Value(project.title),
    description: Value(project.description),
    deadline: Value(project.deadline),
    priority: Value(project.priority),
    status: Value(project.status.name),
    resourceLink: Value(project.resourceLink),
    createdAt: Value(project.createdAt),
    updatedAt: Value(project.updatedAt),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(Project project) => {
    'id': project.id,
    'user_id': project.userId,
    'goal_id': project.goalId,
    'title': project.title,
    'description': project.description,
    'deadline': project.deadline?.toIso8601String(),
    'priority': project.priority,
    'status': project.status.name,
    'resource_link': project.resourceLink,
    'created_at': project.createdAt.toIso8601String(),
    'updated_at': project.updatedAt.toIso8601String(),
  };

  static Project fromRemoteMap(Map<String, dynamic> map) => Project(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    goalId: map['goal_id'] as String?,
    title: map['title'] as String,
    description: map['description'] as String?,
    deadline: map['deadline'] == null
        ? null
        : DateTime.parse(map['deadline'] as String),
    priority: map['priority'] as int,
    status: ProjectStatus.values.byName(map['status'] as String),
    resourceLink: map['resource_link'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
