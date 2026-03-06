import 'package:drift/drift.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';

/// Converts between [GoalRow] (Drift) and [Goal] (domain entity).
///
/// Also handles serialisation to/from Supabase JSON maps.
class GoalModel {
  const GoalModel._();

  static Goal fromRow(GoalRow row) => Goal(
    id: row.id,
    userId: row.userId,
    title: row.title,
    intention: row.intention,
    deadline: row.deadline,
    priority: row.priority,
    status: GoalStatus.values.byName(row.status),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static GoalsTableCompanion toCompanion(
    Goal goal, {
    String syncStatus = 'pendingUpload',
  }) => GoalsTableCompanion(
    id: Value(goal.id),
    userId: Value(goal.userId),
    title: Value(goal.title),
    intention: Value(goal.intention),
    deadline: Value(goal.deadline),
    priority: Value(goal.priority),
    status: Value(goal.status.name),
    createdAt: Value(goal.createdAt),
    updatedAt: Value(goal.updatedAt),
    syncStatus: Value(syncStatus),
  );

  static Map<String, dynamic> toRemoteMap(Goal goal) => {
    'id': goal.id,
    'user_id': goal.userId,
    'title': goal.title,
    'intention': goal.intention,
    'deadline': goal.deadline?.toIso8601String(),
    'priority': goal.priority,
    'status': goal.status.name,
    'created_at': goal.createdAt.toIso8601String(),
    'updated_at': goal.updatedAt.toIso8601String(),
  };

  static Goal fromRemoteMap(Map<String, dynamic> map) => Goal(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    intention: map['intention'] as String,
    deadline: map['deadline'] == null
        ? null
        : DateTime.parse(map['deadline'] as String),
    priority: map['priority'] as int,
    status: GoalStatus.values.byName(map['status'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
