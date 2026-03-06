import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

enum GoalStatus { active, completed, archived, paused }

/// A long-term outcome the user wants to achieve (e.g. "Become an ML Engineer").
///
/// Goals are the top of the hierarchy: Goal → Project → Subtask.
/// A Goal without Projects is valid — the user may add Projects later.
@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required String title,

    /// Why this goal matters to the user. Shown as motivational context.
    required String intention,
    DateTime? deadline,

    /// 1 = highest priority. Used for display ordering.
    required int priority,
    required GoalStatus status,
    required DateTime createdAt,

    /// Updated on every change. Used for sync conflict resolution (last-write-wins).
    required DateTime updatedAt,
  }) = _Goal;
}
