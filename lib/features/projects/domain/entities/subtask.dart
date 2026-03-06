import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask.freezed.dart';

enum SubtaskStatus { pending, inProgress, completed, skipped }

/// A concrete step inside a Project (e.g. "Watch lesson 3 of fast.ai").
///
/// Subtasks are the smallest unit of trackable work.
/// They can be recurring via an iCal RRULE string.
@freezed
abstract class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    required String projectId,
    required String title,
    String? description,
    DateTime? deadline,

    /// Whether this subtask repeats on a schedule.
    required bool isRecurring,

    /// iCal RRULE string (e.g. "FREQ=DAILY;COUNT=15").
    /// Only meaningful when [isRecurring] is true.
    String? recurrenceRule,
    required SubtaskStatus status,

    /// User-defined display order within a project. Lower = shown first.
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subtask;
}
