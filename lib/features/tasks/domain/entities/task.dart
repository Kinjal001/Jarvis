import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

enum TaskStatus { pending, completed, skipped }

/// A standalone one-time action not tied to any Project.
///
/// Use Tasks for quick things that don't belong to a larger effort:
/// "Buy groceries", "Reply to email", etc.
/// For work that belongs to a Project, use Subtask instead.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String userId,
    required String title,
    String? description,
    DateTime? dueDate,
    required int priority,
    required TaskStatus status,
    required bool isRecurring,
    String? recurrenceRule,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;
}
