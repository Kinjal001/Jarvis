import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:jarvis/core/database/database_provider.dart';
import 'package:jarvis/core/supabase/supabase_provider.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/projects/data/datasources/project_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_remote_datasource.dart';
import 'package:jarvis/features/projects/data/repositories/project_repository_impl.dart';
import 'package:jarvis/features/projects/data/repositories/subtask_repository_impl.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';
import 'package:jarvis/features/projects/domain/usecases/archive_project.dart';
import 'package:jarvis/features/projects/domain/usecases/create_project.dart';
import 'package:jarvis/features/projects/domain/usecases/create_subtask.dart';
import 'package:jarvis/features/projects/domain/usecases/get_projects_by_goal.dart';
import 'package:jarvis/features/projects/domain/usecases/get_subtasks_by_project.dart';
import 'package:jarvis/features/projects/domain/usecases/update_subtask_status.dart';

part 'project_providers.g.dart';

// ── Project datasources ───────────────────────────────────────────────────────

@riverpod
ProjectLocalDatasource projectLocalDatasource(Ref ref) {
  return ProjectLocalDatasource(ref.watch(appDatabaseProvider));
}

@riverpod
ProjectRemoteDatasource projectRemoteDatasource(Ref ref) {
  return ProjectRemoteDatasource(ref.watch(supabaseClientProvider));
}

// ── Subtask datasources ───────────────────────────────────────────────────────

@riverpod
SubtaskLocalDatasource subtaskLocalDatasource(Ref ref) {
  return SubtaskLocalDatasource(ref.watch(appDatabaseProvider));
}

@riverpod
SubtaskRemoteDatasource subtaskRemoteDatasource(Ref ref) {
  return SubtaskRemoteDatasource(ref.watch(supabaseClientProvider));
}

// ── Repositories ──────────────────────────────────────────────────────────────

@riverpod
IProjectRepository projectRepository(Ref ref) {
  return ProjectRepositoryImpl(
    ref.watch(projectLocalDatasourceProvider),
    ref.watch(projectRemoteDatasourceProvider),
  );
}

@riverpod
ISubtaskRepository subtaskRepository(Ref ref) {
  return SubtaskRepositoryImpl(
    ref.watch(subtaskLocalDatasourceProvider),
    ref.watch(subtaskRemoteDatasourceProvider),
  );
}

// ── Use cases ─────────────────────────────────────────────────────────────────

@riverpod
GetProjectsByGoal getProjectsByGoal(Ref ref) =>
    GetProjectsByGoal(ref.watch(projectRepositoryProvider));

@riverpod
CreateProject createProject(Ref ref) =>
    CreateProject(ref.watch(projectRepositoryProvider));

@riverpod
ArchiveProject archiveProject(Ref ref) =>
    ArchiveProject(ref.watch(projectRepositoryProvider));

@riverpod
GetSubtasksByProject getSubtasksByProject(Ref ref) =>
    GetSubtasksByProject(ref.watch(subtaskRepositoryProvider));

@riverpod
CreateSubtask createSubtask(Ref ref) =>
    CreateSubtask(ref.watch(subtaskRepositoryProvider));

@riverpod
UpdateSubtaskStatus updateSubtaskStatus(Ref ref) =>
    UpdateSubtaskStatus(ref.watch(subtaskRepositoryProvider));

// ── Project list notifier (scoped to a goal) ──────────────────────────────────

@riverpod
class ProjectList extends _$ProjectList {
  @override
  Future<List<Project>> build(String goalId) async {
    final result = await ref.watch(getProjectsByGoalProvider).call(goalId);
    return result.fold((f) => throw f, (projects) => projects);
  }

  Future<void> create({required String title, required String goalId}) async {
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final project = Project(
      id: const Uuid().v4(),
      userId: user.id,
      goalId: goalId,
      title: title,
      priority: 3,
      status: ProjectStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await ref.read(createProjectProvider).call(project);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> archive(String id) async {
    final result = await ref.read(archiveProjectProvider).call(id);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

// ── Subtask list notifier (scoped to a project) ───────────────────────────────

@riverpod
class SubtaskList extends _$SubtaskList {
  @override
  Future<List<Subtask>> build(String projectId) async {
    final result = await ref
        .watch(getSubtasksByProjectProvider)
        .call(projectId);
    return result.fold((f) => throw f, (subtasks) => subtasks);
  }

  Future<void> create({
    required String title,
    required String projectId,
  }) async {
    final subtask = Subtask(
      id: const Uuid().v4(),
      projectId: projectId,
      title: title,
      isRecurring: false,
      status: SubtaskStatus.pending,
      sortOrder: state.valueOrNull?.length ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await ref.read(createSubtaskProvider).call(subtask);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> updateStatus(String id, SubtaskStatus status) async {
    final result = await ref.read(updateSubtaskStatusProvider).call(id, status);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}
