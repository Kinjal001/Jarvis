import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

enum ProjectStatus { active, completed, archived, paused }

/// A concrete effort under a Goal (e.g. "Complete Fast.ai course").
///
/// A Project can optionally belong to a Goal via [goalId].
/// A Project without a Goal is valid — the user may not always have a parent goal.
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String userId,

    /// Optional parent goal. Null means this is a standalone project.
    String? goalId,
    required String title,
    String? description,
    DateTime? deadline,
    required int priority,
    required ProjectStatus status,

    /// URL or local file path for a reference resource (e.g. an Obsidian vault path).
    String? resourceLink,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Project;
}
