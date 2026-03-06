import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';

class SubtaskModel {
  const SubtaskModel._();

  static Subtask fromRow(SubtaskRow row) => Subtask(
    id: row.id,
    projectId: row.projectId,
    title: row.title,
    description: row.description,
    deadline: row.deadline,
    isRecurring: row.isRecurring,
    recurrenceRule: row.recurrenceRule,
    status: SubtaskStatus.values.byName(row.status),
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static SubtasksTableCompanion toCompanion(
    Subtask subtask, {
    String syncStatus = 'pendingUpload',
  }) => SubtasksTableCompanion(
    id: Value(subtask.id),
    projectId: Value(subtask.projectId),
    title: Value(subtask.title),
    description: Value(subtask.description),
    deadline: Value(subtask.deadline),
    isRecurring: Value(subtask.isRecurring),
    recurrenceRule: Value(subtask.recurrenceRule),
    status: Value(subtask.status.name),
    sortOrder: Value(subtask.sortOrder),
    createdAt: Value(subtask.createdAt),
    updatedAt: Value(subtask.updatedAt),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(Subtask subtask) => {
    'id': subtask.id,
    'project_id': subtask.projectId,
    'title': subtask.title,
    'description': subtask.description,
    'deadline': subtask.deadline?.toIso8601String(),
    'is_recurring': subtask.isRecurring,
    'recurrence_rule': subtask.recurrenceRule,
    'status': subtask.status.name,
    'sort_order': subtask.sortOrder,
    'created_at': subtask.createdAt.toIso8601String(),
    'updated_at': subtask.updatedAt.toIso8601String(),
  };

  static Subtask fromRemoteMap(Map<String, dynamic> map) => Subtask(
    id: map['id'] as String,
    projectId: map['project_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    deadline: map['deadline'] == null
        ? null
        : DateTime.parse(map['deadline'] as String),
    isRecurring: map['is_recurring'] as bool,
    recurrenceRule: map['recurrence_rule'] as String?,
    status: SubtaskStatus.values.byName(map['status'] as String),
    sortOrder: map['sort_order'] as int,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
