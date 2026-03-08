import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';

class TaskModel {
  const TaskModel._();

  static Task fromRow(TaskRow row) => Task(
    id: row.id,
    userId: row.userId,
    title: row.title,
    description: row.description,
    dueDate: row.dueDate,
    priority: row.priority,
    status: TaskStatus.values.byName(row.status),
    isRecurring: row.isRecurring,
    recurrenceRule: row.recurrenceRule,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static TasksTableCompanion toCompanion(
    Task task, {
    String syncStatus = 'pendingUpload',
  }) => TasksTableCompanion(
    id: Value(task.id),
    userId: Value(task.userId),
    title: Value(task.title),
    description: Value(task.description),
    dueDate: Value(task.dueDate),
    priority: Value(task.priority),
    status: Value(task.status.name),
    isRecurring: Value(task.isRecurring),
    recurrenceRule: Value(task.recurrenceRule),
    createdAt: Value(task.createdAt),
    updatedAt: Value(task.updatedAt),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(Task task) => {
    'id': task.id,
    'user_id': task.userId,
    'title': task.title,
    'description': task.description,
    'due_date': task.dueDate?.toIso8601String(),
    'priority': task.priority,
    'status': task.status.name,
    'is_recurring': task.isRecurring,
    'recurrence_rule': task.recurrenceRule,
    'created_at': task.createdAt.toIso8601String(),
    'updated_at': task.updatedAt.toIso8601String(),
  };

  static Task fromRemoteMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    dueDate: map['due_date'] == null
        ? null
        : DateTime.parse(map['due_date'] as String),
    priority: map['priority'] as int,
    status: TaskStatus.values.byName(map['status'] as String),
    isRecurring: map['is_recurring'] as bool,
    recurrenceRule: map['recurrence_rule'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
